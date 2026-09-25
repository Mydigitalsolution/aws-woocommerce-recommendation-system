SELECT
  a.product_id AS product_id,
  b.product_id AS recommended_product,
  COUNT(*) AS score
FROM wc_events a
JOIN wc_events b ON a.user_id = b.user_id
WHERE a.product_id <> b.product_id
  AND a.event_type = 'product_view'
  AND b.event_type = 'product_view'
GROUP BY a.product_id, b.product_id
ORDER BY product_id, score DESC;
