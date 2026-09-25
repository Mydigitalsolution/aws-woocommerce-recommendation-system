CREATE DATABASE IF NOT EXISTS wc_recommendations;

-- Adapt schema and location to your actual implementation.
CREATE EXTERNAL TABLE IF NOT EXISTS wc_recommendations.wc_events (
  user_id string,
  product_id string,
  event_type string,
  timestamp string
)
PARTITIONED BY (year string, month string, day string)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
LOCATION 's3://YOUR_BUCKET_NAME/events/';

SELECT * FROM wc_recommendations.wc_events LIMIT 10;
