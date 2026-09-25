# AWS Service Decisions

## Lambda vs ECS Fargate
Lambda fits lightweight event-driven processing and avoids server management. ECS Fargate is an alternative for long-running containerized workloads needing greater CPU/memory control and predictable runtime characteristics. Fargate is pay-as-you-go rather than a permanent free service.

## API Gateway vs ALB
API Gateway fits lightweight REST endpoints integrated with Lambda. ALB is a natural alternative for ECS/EC2/container services.

## Athena vs RDS
Athena queries data directly in S3 using SQL without managing a database server. RDS is better suited to transactional relational workloads requiring frequent row-level operations.

## S3 vs traditional database
S3 provides scalable object storage for raw JSON event data and works naturally with Athena.

## Glue Crawler vs manual table
The Glue Crawler was tested but removed from the final architecture because manually defining the Athena external table provided more control. Athena still uses the Glue Data Catalog for table metadata.

## EventBridge vs cron
EventBridge Scheduler is a managed AWS scheduling service and avoids maintaining a cron server.

## Kinesis
Kinesis was considered for real-time streaming, but the project does not require continuous high-volume streaming. S3 + Athena + scheduled processing is simpler for this implementation.

## Future options
ECS Fargate, SageMaker, Kinesis, AWS WAF, CloudFront, and Secrets Manager can be evaluated as requirements grow.
