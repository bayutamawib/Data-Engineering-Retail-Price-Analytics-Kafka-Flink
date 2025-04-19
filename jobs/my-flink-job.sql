CREATE CATALOG test_pg WITH (
  'type' = 'jdbc',
  'default-database' = 'dna_project',
  'username' = 'dna_project_owner',
  'password' = '*******',
  'base-url' = 'jdbc:postgresql://ep-orange-star-a10mj9ay.ap-southeast-1.aws.neon.tech:5432'
);

-- Reference sink via the catalog instead of raw JDBC
USE CATALOG test_pg;
USE dna_project;

-- No need to re-create the sink if already exists in the catalog:
-- Just run the INSERT statement
-- Transformation Tasks
INSERT INTO `fact.dim_customer`
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
FROM `dm.dim_customer`
