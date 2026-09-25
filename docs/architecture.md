# Architecture

## Data flow

```text
Customer
   |
   v
WooCommerce
   |
   v
WordPress Plugin
   |
   | HTTPS + CORS + API Secret
   v
API Gateway
   |
   v
Event Receiver Lambda
   |
   | IAM
   v
S3 Raw Events
   |
   v
Glue Data Catalog
   |
   v
Athena
   |
   | SQL co-occurrence analysis
   v
Recommendation Lambda
   |
   v
S3 recommendations.json
   |
   v
WooCommerce Plugin
   |
   v
Recommended Products
```

EventBridge Scheduler independently triggers the Recommendation Lambda on a schedule (hourly/daily) — it's not part of the request-driven path above, but runs alongside it.

## Glue Data Catalog vs. Glue Crawler

These are easy to conflate, so to be precise:

- **AWS Glue Data Catalog** *is* part of the final architecture — Athena uses it to store the external table's metadata (column names, types, S3 location, partition structure).
- **AWS Glue Crawler** is *not* part of the final architecture. It was tested during development but replaced with a manually-defined Athena external table (see [`sql/create_tables.sql`](../sql/create_tables.sql)) for more direct schema control. See [Service Decisions](service-decisions.md) for the full rationale.

The actual event data always remains in S3 — Athena reads it directly from S3 at query time using the catalog's metadata; nothing is copied into a separate database.

## Terminology to keep consistent

To avoid inaccurate descriptions creeping into documentation or presentations, use these terms consistently:

- WooCommerce website
- WordPress/WooCommerce plugin
- API Gateway
- Event Receiver Lambda
- Recommendation Lambda
- S3
- Athena
- Glue Data Catalog
- EventBridge Scheduler
- IAM
- CORS
- API secret
- product co-occurrence
- recommendation output
- `recommendations.json`

**Avoid** these inaccurate framings:

| Don't say | Say instead |
|---|---|
| "Glue stores the data." | "S3 stores the data; Glue Data Catalog stores metadata." |
| "Athena imports the JSON into a database." | "Athena queries JSON data directly in S3 through an external table." |
| "CORS authenticates the API." | "CORS controls browser cross-origin access; the API secret provides application-level authentication." |

## One-paragraph explanation (useful for presentations)

> The WooCommerce plugin captures customer product-view events and sends them through API Gateway. Lambda validates the request and stores the event as JSON in S3. Athena queries those events using metadata registered in the Glue Data Catalog. A recommendation Lambda calculates product co-occurrence and writes the recommendations to S3. EventBridge Scheduler periodically triggers the recommendation process, and the WooCommerce plugin uses the resulting JSON to display recommended products.
