# Infrastructure

This project is deployed manually through the AWS Console rather than via Infrastructure-as-Code (see [Future Improvements](../docs/future-improvements.md) for CDK/CloudFormation/Terraform as a potential next step). Document your own deployment's specifics here — resource names, regions, roles, and API stages — using placeholders in any content that ends up in version control.

## What to record here (locally, never with real secrets committed)

- **Region:** which AWS region the stack is deployed in
- **S3 bucket name:** replace with `YOUR_BUCKET_NAME` in any committed docs/code
- **API Gateway:** API ID/URL, whether it's an HTTP API or REST API, and the deployed stage name
- **Lambda functions:** the Event Receiver Lambda and Recommendation Lambda function names and their execution role ARNs
- **Athena:** workgroup name, database name (`wc_recommendations`), and query result output location
- **Glue Data Catalog:** database/table names registered for Athena
- **EventBridge Scheduler:** schedule name, expression (e.g. hourly/daily), and target Lambda

## AWS Console navigation reference

**API Gateway:** Console → API Gateway → select API → Routes/Resources (for CORS: API → CORS). Exact menu labels differ between HTTP API and REST API.

**Lambda:** Console → Lambda → Functions → select function. For IAM: Function → Configuration → Permissions → Execution role.

**S3:** Console → S3 → Buckets → select bucket → inspect `events/` and `recommendations/` prefixes.

**Athena:** Console → Athena → Query editor → select database → run SQL (e.g. `SELECT * FROM wc_events LIMIT 10;`).

**EventBridge Scheduler:** Console → EventBridge → Scheduler → Schedules → select schedule → inspect the schedule expression, enabled/disabled status, target Lambda, and execution role.

## Deployment notes

Never commit credentials, real resource ARNs with account IDs, or the real API secret to this file or anywhere else in the repository. See [`docs/deployment.md`](../docs/deployment.md) for the full step-by-step replication guide.
