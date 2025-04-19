This is a Data Engineering Pipeline for Retail Price Analytics using neondb PostgreSQL, Apache Airflow, Kafka, and Flink.
We used Flink SQL clients for data transformation whether for regular streaming or involving aggregation.

All Flink pipeline jobs are stored in jobs folder:
https://github.com/bayutamawib/Data-Engineering-Retail-Price-Analytics-Kafka-Flink/tree/90db7f619aae4b73ea4ad7c81ba0573e389df912/jobs

Below here are the functions of each flink Jobs:
  1. my-flink-job.sql       = Streaming data from source database to sink database directly using flink only.
  2. my-kafka-flink-job.sql = Streaming data from source database to kafka, processed it using flink, and send it to sink database.
  3. transform-test.sql     = Streaming data from source database to kafka, processed it using flink, and send it to sink database but in a form of report
                               (its basically a pipeline to create an auto-updated report of product price's average, it will sync the average price
                               each time a new price data is inserted in the source database).
