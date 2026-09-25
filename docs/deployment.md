# Deployment / Replication Guide

1. Prepare a working WooCommerce/WordPress site and custom plugin.
2. Create an S3 bucket with public access blocked.
3. Create the Node.js event-receiver Lambda and its least-privilege IAM role.
4. Configure bucket/region/origin settings without exposing secrets.
5. Create API Gateway and routes such as `POST /events` and the recommendations route.
6. Integrate routes with Lambda and deploy.
7. Configure CORS for the authorized WooCommerce origin; allow only required methods/headers and handle OPTIONS preflight.
8. Configure API-secret authentication. Do not commit the real secret.
9. Trigger a WooCommerce event and verify JSON appears in S3.
10. Create an Athena database and external `wc_events` table over the S3 event prefix.
11. Test with `SELECT * FROM wc_events LIMIT 10;`.
12. Run the recommendation SQL.
13. Create the recommendation Node.js Lambda with only required Athena/S3 permissions.
14. Test that it creates `recommendations.json`.
15. Open EventBridge → Scheduler/Schedules and create a schedule targeting the recommendation Lambda.
16. Verify Lambda logs and S3 output.
17. Configure the WordPress plugin to retrieve recommendations.
18. Test the complete flow from WooCommerce to recommendations.

Example event:
```json
{
  "user_id":"TEST_USER",
  "product_id":"158",
  "event_type":"product_view",
  "timestamp":"2026-09-21T00:00:00Z"
}
```

Security checklist:
- Block public S3 access.
- Use least-privilege IAM.
- Restrict CORS.
- Validate requests.
- Authenticate API calls.
- Keep secrets out of Git.
- Monitor with CloudWatch.
- Consider Secrets Manager and WAF for production.
