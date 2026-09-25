# Security

## Current controls

### CORS
Restricts which browser origins may call the API Gateway endpoint (e.g. only `https://your-store-domain.com`), with allowed methods limited to `POST`, `GET`, `OPTIONS` and allowed headers limited to `Content-Type`, `x-api-secret`.

**CORS is not authentication.** It controls which browser origins are permitted to make cross-origin requests — it says nothing about whether a given request is authorized.

### API Secret
A shared application secret sent as the `x-api-secret` header by the WordPress plugin and validated by the Event Receiver Lambda. This is the actual authentication mechanism — CORS and the API secret are complementary, not interchangeable:

```text
CORS       = browser origin control
API Secret = application-level authentication
```

### Input validation
The Event Receiver Lambda validates the incoming payload shape before writing anything to S3, rejecting malformed or unexpected requests.

### IAM least privilege
Each Lambda's execution role is scoped to only what it needs — e.g. the Event Receiver Lambda has `s3:PutObject` on its specific bucket/prefix, nothing broader. See each component's README under `backend/` for its exact required permissions.

### Private S3
Public access is blocked on the S3 bucket. Athena, the Lambdas, and any other consumer access it via IAM roles, never via public URLs.

## Production improvements (not yet implemented)

- **AWS Secrets Manager** for storing and rotating the API secret instead of a static value.
- **AWS WAF** in front of API Gateway for additional protection against abusive or malicious traffic.
- **CloudWatch monitoring** — dashboards and alarms for Lambda errors, invocation volume, and latency.
- **Stronger authentication** (e.g. signed requests or JWTs) if the shared-secret approach proves insufficient at scale.

See [`docs/future-improvements.md`](../docs/future-improvements.md) for the fuller roadmap.

## GitHub security rules

Never commit:
- AWS access keys or secret keys
- API secrets
- Passwords or database credentials
- Private customer information
- Private tokens

Use placeholders in all documentation and code: `YOUR_BUCKET_NAME`, `YOUR_API_URL`, `YOUR_API_SECRET`. The repository's `.gitignore` excludes common secret/config file patterns (`.env`, `*.pem`, `*.key`, `credentials*`, `.aws/`) by default.
