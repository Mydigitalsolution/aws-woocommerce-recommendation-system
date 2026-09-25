# Challenges Encountered

This project surfaced a number of real implementation and debugging challenges during development. They're documented here because they're useful evidence of problem-solving for the academic report, and because future maintainers will likely hit the same issues.

## API Gateway configuration
Getting routes, integrations, and stages configured correctly for a Lambda-backed HTTP API required care — the exact console labels and required steps differ between an HTTP API and a REST API.

## CORS configuration
CORS needed to be scoped precisely to the WooCommerce store's origin, with the correct allowed methods (`POST`, `GET`, `OPTIONS`) and headers (`Content-Type`, `x-api-secret`), including proper handling of the `OPTIONS` preflight request. It's easy to conflate CORS with authentication — they are not the same thing:

```text
CORS       = browser origin control
API Secret = application-level authentication
```

A valid CORS configuration does not prove a request is authorized, and an API secret does not replace correct CORS configuration for browser clients.

## IAM permissions
Each Lambda's execution role needed exactly the permissions it required (e.g. `s3:PutObject` on the specific bucket/prefix) — not broad or administrator access. Getting least-privilege policies right, especially for the recommendation Lambda's Athena + S3 access, took iteration.

## S3 event storage
Ensuring incoming events landed at the correct S3 key structure (`events/year=YYYY/month=MM/day=DD/...`) so that Athena's partitioned external table could actually see them required careful alignment between the Lambda's write path and the table definition.

## Athena table configuration
The external table's schema, SerDe, and S3 location all had to match the actual JSON structure being written — mismatches here silently return empty results rather than obvious errors.

## Glue Crawler / manual table experiments
The Glue Crawler was tested early on but ultimately dropped in favor of manually defining the Athena external table (see [Glue Crawler Decision](service-decisions.md)) for more direct schema control.

## Lambda timeout issues
The recommendation Lambda's Athena query + result processing needed enough timeout headroom configured, since Athena queries are asynchronous and require polling for completion.

## Recommendation output validation
Verifying that `recommendations.json` actually reflected the expected co-occurrence logic — and wasn't silently empty or malformed — needed explicit test cases against known event data.

## S3 recommendation file handling
Coordinating overwrites of `recommendations.json` on each scheduled run (rather than accumulating stale or duplicate files) required a defined, consistent output path.

## EventBridge scheduling
Configuring the schedule expression, target Lambda, and execution role/permissions for EventBridge Scheduler to reliably invoke the recommendation Lambda on schedule.

## WooCommerce native recommendations being confused with AWS recommendations
WooCommerce has its own built-in "related products" behavior, which can be easily mistaken for the custom AWS-generated recommendations during testing. **Clearing the S3 recommendation file does not remove WooCommerce's native related products** — when debugging, always verify that the products displayed are actually coming from the custom plugin's AWS-backed logic, not WooCommerce's built-in feature.

## Kinesis considered but not adopted
Kinesis was evaluated for real-time event streaming but ultimately deemed unnecessary — this project doesn't require continuous high-volume streaming, and scheduled batch processing (S3 + Athena + EventBridge) is simpler to build, debug, and demonstrate.

## Questions about Lambda's production suitability
It's inaccurate to describe Lambda as simply "unable to handle production." The more accurate framing: Lambda suits event-driven, short-running workloads, while ECS Fargate offers more control for long-running containerized workloads with predictable resource needs. The right choice depends on runtime duration, memory/CPU requirements, concurrency, and cost — not a blanket "Lambda isn't production-ready" claim.
