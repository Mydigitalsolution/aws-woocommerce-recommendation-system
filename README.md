# AWS WooCommerce Product Recommendation System

A cloud-native, serverless product recommendation system for WooCommerce, built on AWS. Customer product-view events are captured from the storefront, streamed into a data lake, analyzed with SQL, and turned into "customers who viewed this also viewed" recommendations — all without running or managing a dedicated server.

## Business Problem

The WooCommerce store already collects customer product-view and related shopping events, but had no way to turn that raw behavioral data into product recommendations. This project builds a practical, low-cost AWS pipeline that:

1. Captures WooCommerce customer events
2. Sends those events securely to AWS
3. Stores raw event data in Amazon S3
4. Queries the data with Amazon Athena
5. Uses product co-occurrence to generate recommendations
6. Stores recommendation output in S3
7. Automatically refreshes recommendations on a schedule (EventBridge Scheduler)
8. Returns recommendations to WooCommerce through a custom WordPress plugin

This is an academic/cloud architecture project, deliberately designed around AWS free-tier/low-cost services rather than a full production-grade deployment.

## Architecture

```text
Customer
   |
   v
WooCommerce Website
   |
   v
WordPress/WooCommerce Recommendation Plugin
   |
   | HTTPS request
   | CORS + API Secret
   v
Amazon API Gateway
   |
   v
Event Receiver Lambda
(Node.js / JavaScript)
   |
   | IAM permission
   v
Amazon S3
(raw event JSON)
   |
   v
Amazon Athena  <---- AWS Glue Data Catalog (table metadata)
   |
   | SQL recommendation query
   v
Recommendation Lambda
   |
   v
Amazon S3
(recommendations.json)
   |
   | Scheduled refresh
   ^
EventBridge Scheduler
   |
   v
WordPress/WooCommerce Plugin
   |
   v
Recommended WooCommerce Products
```

**Important clarification:** the Glue Data Catalog is part of the final architecture — it stores the Athena table's metadata (columns, types, S3 location, partitions). The **Glue Crawler is not** part of the final design; the external table is defined manually via SQL instead (see [Service Decisions](docs/service-decisions.md) for why).

## Components

| Component | Responsibility |
|---|---|
| **WordPress/WooCommerce plugin** | Captures `product_view`, `add_to_cart`, and `purchase` events; sends them to API Gateway; retrieves and displays recommendations |
| **API Gateway** | Public HTTPS entry point; enforces CORS |
| **Event Receiver Lambda** (Node.js) | Validates the API secret and payload, writes valid events to S3 as JSON |
| **IAM** | Least-privilege execution roles for both Lambdas and the EventBridge target |
| **S3** | Data lake for raw event JSON (`events/`) and generated recommendation output (`recommendations/`) |
| **Athena** | Runs the co-occurrence SQL directly against the S3 event data via an external table |
| **Glue Data Catalog** | Stores the Athena external table's metadata (not the data itself) |
| **Recommendation Lambda** (Node.js) | Runs the Athena query, processes co-occurrence scores, writes `recommendations.json` to S3 |
| **EventBridge Scheduler** | Triggers the Recommendation Lambda on a schedule (hourly/daily), replacing a cron server |

## Recommendation Approach

The system uses **product co-occurrence**, not a trained machine learning model: if the same users viewed two different products, those products accumulate a co-occurrence score. Higher co-occurrence produces a stronger relationship.

```text
User A viewed: Product 158, Product 135
User B viewed: Product 158, Product 154
User C viewed: Product 158, Product 135

→ Product 158 co-occurs with: 135 (score 2), 154 (score 1)
```

Example output:
```json
{"product_id":"158","recommendations":["135","154"]}
```

See [`sql/recommendations.sql`](sql/recommendations.sql) for the exact query.

## Repository Structure

```text
aws-woocommerce-recommendation-system/
├── README.md
├── .gitignore
├── LICENSE
├── architecture/
│   └── README.md              # Where to place the final architecture diagram image
├── backend/
│   ├── event-receiver/
│   │   └── README.md          # Event Receiver Lambda responsibilities & IAM needs
│   └── recommendation-engine/
│       └── README.md          # Recommendation Lambda responsibilities & IAM needs
├── data/
│   └── sample-events.json     # Example event payload for testing
├── docs/
│   ├── architecture.md        # Data flow + Glue Data Catalog vs Glue Crawler clarification
│   ├── deployment.md          # Full step-by-step replication guide
│   ├── service-decisions.md   # Why each AWS service was chosen over its alternatives
│   ├── challenges.md          # Real implementation/debugging challenges encountered
│   └── future-improvements.md # Roadmap for hardening this toward production
├── infrastructure/
│   └── README.md              # AWS resource names, regions, roles, deployment notes
├── security/
│   └── README.md              # CORS, API secret, IAM, and production security roadmap
├── sql/
│   ├── create_tables.sql      # Athena external table definition
│   └── recommendations.sql    # Product co-occurrence query
└── wordpress/
    └── README.md              # WooCommerce plugin responsibilities
```

> **Note on scope:** this repository currently documents the architecture, SQL, and integration contract in full detail. The Lambda function source (Node.js) and the WordPress/WooCommerce plugin (PHP) are referenced throughout the docs by their responsibilities and I/O contracts, but the implementation files themselves are maintained separately — see each component's README for what it's responsible for and what interface it exposes.

## Security

- **CORS** restricts which browser origins may call the API — this is *not* authentication.
- **API secret** (`x-api-secret` header) provides application-level authentication, validated by the Event Receiver Lambda.
- **IAM least privilege** — each Lambda's execution role has only the permissions it needs (e.g. `s3:PutObject` on the specific bucket/prefix, not broad access).
- **Private S3** — public access is blocked; Athena/Lambda access the bucket via IAM, not public URLs.
- **Input validation** — the Event Receiver Lambda validates the payload shape before writing anything to S3.

Full details in [`security/README.md`](security/README.md) and [`docs/deployment.md`](docs/deployment.md).

## Why These Services (Not Alternatives)

| Chosen | Instead of | Why |
|---|---|---|
| Lambda | ECS Fargate | Lightweight, event-driven processing without managing servers or containers; Fargate is a better fit for long-running workloads needing predictable CPU/memory |
| API Gateway | Application Load Balancer | Purpose-built for lightweight REST endpoints integrated directly with Lambda |
| Athena | RDS | Queries JSON directly in S3 with no database server to manage; RDS fits transactional, row-level-update workloads better |
| S3 | Traditional database | Scalable, inexpensive object storage that Athena can query natively |
| Manual Athena table | Glue Crawler | Tested during development, but manual table definition gives more direct control over schema and partitions with fewer moving parts |
| EventBridge Scheduler | Cron server | Managed AWS scheduling — no server to maintain |
| Scheduled batch (Athena) | Kinesis | The project doesn't need continuous high-volume streaming; scheduled batch processing is simpler for this workload |

Full rationale in [`docs/service-decisions.md`](docs/service-decisions.md).

## Getting Started (Replication)

See [`docs/deployment.md`](docs/deployment.md) for the full 18-step guide, covering: WooCommerce/plugin setup → S3 bucket → Event Receiver Lambda + IAM → API Gateway + CORS → API secret → Athena external table → Recommendation Lambda → EventBridge schedule → verifying the full loop back into WooCommerce.

## Academic Project Context

This project was built to satisfy a course rubric emphasizing: a real-world business problem, a functional (not just theoretical) AWS deployment, clear justification for each service choice, a documented architecture, working code, a deployment walkthrough, documented challenges, and reflection on what could be improved. See [`docs/challenges.md`](docs/challenges.md) and [`docs/future-improvements.md`](docs/future-improvements.md) for the challenges-encountered and reflection components.

## Important

**Never commit real AWS keys, API secrets, passwords, or private customer data.** Replace placeholders such as `YOUR_BUCKET_NAME`, `YOUR_API_URL`, and `YOUR_API_SECRET` with your own values locally — never in version control. See `.gitignore` for what's already excluded.

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
