-- Register source tables
CREATE TABLE `neondb.dm.dim_customer` (
  `sk_customer` INT,
  `customer_id` INT,
  `customer_first_name` STRING,
  `customer_middle_initial_name` STRING,
  `customer_last_name` STRING,
  `customer_address` STRING,
  `customer_city_id` INT,
  `customer_city_name` STRING,
  `customer_zipcode` STRING,
  `customer_country_id` INT,
  `customer_country_name` STRING,
  `customer_country_code` STRING,
  `start_date` DATE,
  `end_date` DATE,
  `__deleted` STRING,
  `__op` STRING,
  `__source_ts_ms` BIGINT,
  `__transaction_id` STRING
) WITH (
    'connector' = 'kafka',
    'topic' = 'neondb.dm.dim_customer',
    'properties.bootstrap.servers' = 'kafka-1:9092,kafka-2:9092,kafka-3:9092',
    'format' = 'avro-confluent',
    'avro-confluent.schema-registry.url' = 'http://schema-registry:8081',
    'scan.startup.mode' = 'earliest-offset'
);


-- Register a sink tables
CREATE TABLE `dim_customer` (
  `sk_customer` INT,
  `customer_id` INT,
  `customer_first_name` STRING,
  `customer_middle_initial_name` STRING,
  `customer_last_name` STRING,
  `customer_address` STRING,
  `customer_city_id` INT,
  `customer_city_name` STRING,
  `customer_zipcode` STRING,
  `customer_country_id` INT,
  `customer_country_name` STRING,
  `customer_country_code` STRING,
  `start_date` DATE,
  `end_date` DATE
) WITH (
  'connector' = 'jdbc',
  'url' = 'jdbc:postgresql://ep-orange-star-a10mj9ay.ap-southeast-1.aws.neon.tech:5432/dna_project?sslmode=require',
  'table-name' = 'fact.dim_customer',
  'username' = 'dna_project_owner',
  'password' = 'npg_3KULjo5SaevN',
  'driver' = 'org.postgresql.Driver',
  'sink.buffer-flush.max-rows' = '100',
  'sink.buffer-flush.interval' = '2s'
);


-- Transformation Tasks
INSERT INTO `dim_customer`
SELECT
  `sk_customer`,
  `customer_id`,
  `customer_first_name`,
  `customer_middle_initial_name`,
  `customer_last_name`,
  `customer_address`,
  `customer_city_id`,
  `customer_city_name`,
  `customer_zipcode`,
  `customer_country_id`,
  `customer_country_name`,
  `customer_country_code`,
  `start_date`,
  `end_date`
FROM `neondb.dm.dim_customer`
WHERE __op IN ('r', 'c', 'u') AND (__deleted IS NULL OR __deleted = 'false');