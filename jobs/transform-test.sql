-- Register source tables
CREATE TABLE `neondb.dm.dim_product` (
  sk_product INT,
  product_id INT,
  product_name STRING,
  product_price numeric(18,2),
  category_id INT,
  category_name STRING,
  modify_datetime timestamp(3),
  insert_date DATE,
  __deleted STRING,
  __op STRING,
  __source_ts_ms BIGINT,
  __transaction_id STRING,
  proctime AS PROCTIME()
) WITH (
    'connector' = 'kafka',
    'topic' = 'neondb.dm.dim_product',
    'properties.bootstrap.servers' = 'kafka-1:9092,kafka-2:9092,kafka-3:9092',
    'format' = 'avro-confluent',
    'avro-confluent.schema-registry.url' = 'http://lcoalhost:8081',
    'scan.startup.mode' = 'latest-offset'
);

-- Register a sink tables
CREATE TABLE `product_price_avg` (
  category_name STRING,
  average_price numeric(18,2),
  PRIMARY KEY (category_name) NOT ENFORCED
) WITH (
  'connector' = 'jdbc',
  'url' = 'jdbc:postgresql://ep-orange-star-a10mj9ay.ap-southeast-1.aws.neon.tech:5432/dna_project?sslmode=require',
  'table-name' = 'fact.product_price_avg',
  'username' = 'dna_project_owner',
  'password' = 'npg_3KULjo5SaevN',
  'driver' = 'org.postgresql.Driver',
  'sink.buffer-flush.max-rows' = '1',
  'sink.buffer-flush.interval' = '2s'
);

-- Transformation Task
INSERT INTO `product_price_avg` 
SELECT
  category_name,
  avg(product_price) as average_price
FROM `neondb.dm.dim_product`
WHERE __op IN ('r', 'c', 'u') AND (__deleted IS NULL OR __deleted = 'false')
GROUP BY 
  category_name,
  TUMBLE(proctime(), INTERVAL '1' MINUTE);