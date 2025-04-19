import requests
import json

schema_registry_url = "http://16.78.248.35:8081"
topic = "neondb.dm.dim_customer"

url = f"{schema_registry_url}/subjects/{topic}-value/versions/latest"
resp = requests.get(url)

if resp.status_code != 200:
    print(f"Error fetching schema: {resp.status_code}")
    print(resp.text)
    exit(1)

schema_data = resp.json()
schema_str = schema_data['schema']
schema = json.loads(schema_str)

# Mapping from Avro types to Flink SQL types
type_mapping = {
    "string": "STRING",
    "int": "INT",
    "long": "BIGINT",
    "float": "FLOAT",
    "double": "DOUBLE",
    "boolean": "BOOLEAN",
    "bytes": "BYTES"
}

def map_type(avro_type):
    if isinstance(avro_type, list):
        non_null_types = [t for t in avro_type if t != "null"]
        if non_null_types:
            return map_type(non_null_types[0])
        else:
            return "STRING"


    elif isinstance(avro_type, dict):
        connect_name = avro_type.get("connect.name")
        logical_type = avro_type.get("logicalType")
        base_type = avro_type["type"]

        if connect_name == "io.debezium.time.Date" or logical_type == "date":
            return "DATE"
        elif logical_type == "timestamp-millis":
            return "TIMESTAMP(3)"
        elif logical_type == "timestamp-micros":
            return "TIMESTAMP(6)"
        elif logical_type == "date":
            return "DATE"
        elif logical_type == "time-millis":
            return "TIME"
        elif logical_type == "decimal":
            precision = avro_type.get("precision", 38)
            scale = avro_type.get("scale", 18)
            return f"DECIMAL({precision}, {scale})"

        # fallback for other logical/complex types
        return type_mapping.get(base_type, "STRING")

    return type_mapping.get(avro_type, "STRING")

# Generate Flink SQL column definitions
columns = []
for field in schema['fields']:
    field_name = field['name']
    field_type = map_type(field['type'])
    print(f"Mapping: {field_name} -> {field_type} ({field['type']})")
    columns.append(f"  `{field_name}` {field_type}")

columns_str = ",\n".join(columns)

# Generate CREATE TABLE statement
sql = f""" CREATE TABLE `{topic}` (
{columns_str}
) WITH (
    'connector' = 'kafka',
    'topic' = '{topic}',
    'properties.bootstrap.servers' ='kafka:9092',
    'format' = 'avro-confluent',
    'avro-confluent.schema-registry.url' = '{schema_registry_url}',
    'scan.startup.mode' = 'earliest-offset'
);
"""

print("\n Generated Flink SQL:\n")
print(sql)