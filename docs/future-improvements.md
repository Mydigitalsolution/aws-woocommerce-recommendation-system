# Future Improvements

This project intentionally stays focused on demonstrating a working AWS serverless recommendation pipeline rather than adding services for their own sake. The core flow should be preserved when making changes:

```text
WooCommerce → Plugin → API Gateway → Event Lambda → S3
→ Athena / Glue Catalog → Recommendation Lambda → S3 recommendations → WooCommerce
```

Potential improvements, roughly grouped:

## Security hardening
1. **AWS Secrets Manager** for storing and rotating the API secret, instead of a static header value.
2. **AWS WAF** in front of API Gateway for additional protection against abusive traffic.
3. **CloudWatch dashboards/alarms** for monitoring Lambda errors, invocation counts, and latency.
4. **Stronger authentication** — e.g. signed requests or JWTs — if the shared-secret approach proves insufficient.

## Recommendation quality
5. **Category filtering** — avoid recommending products from unrelated categories.
6. **Minimum co-occurrence thresholds** — suppress low-confidence pairs (e.g. score of 1) that may just be noise.
7. **Popularity weighting** — balance raw co-occurrence against overall product popularity to avoid always surfacing best-sellers.
8. **Time-decay weighting** — give more recent viewing behavior more influence than older events.
9. **More sophisticated collaborative filtering** — move beyond simple co-occurrence toward matrix-factorization or similar techniques.
10. **Machine-learning recommendations** — a genuine trained model (e.g. via Amazon Personalize or SageMaker), as a step beyond the current rule-based co-occurrence approach.
11. **Better handling of anonymous users** — the current design assumes a `user_id`; a real store needs a strategy for pre-login/anonymous session tracking.

## Infrastructure & operations
12. **Data partitioning and optimization** — tune the S3 partition scheme and file sizes for more efficient Athena queries as event volume grows.
13. **Infrastructure as Code** — automate deployment with AWS CDK, CloudFormation, or Terraform instead of manual console configuration.
14. **CI/CD** — deploy Lambda updates and infrastructure changes via GitHub Actions.
15. **ECS Fargate** — reconsider for the recommendation engine if workload requirements grow beyond what's comfortable in a short-lived Lambda invocation.

None of these are required for the current academic scope — they represent a realistic path from "working prototype" to "production-hardened system," which is worth documenting even if not implemented.
