# WooCommerce Plugin

A custom WordPress/WooCommerce plugin that acts as the integration layer between the storefront and the AWS backend.

## Responsibilities

- Detecting product events on the storefront (product views, add-to-cart, purchases).
- Sending event data to AWS via HTTPS (through API Gateway).
- Requesting recommendation results from AWS.
- Matching returned recommendation product IDs to actual WooCommerce products.
- Displaying recommended products to the customer.

## Event types sent

- `product_view`
- `add_to_cart`
- `purchase`

## Example event payload

```json
{
  "user_id": "TEST_USER",
  "product_id": "158",
  "event_type": "product_view",
  "timestamp": "2026-09-21T00:00:00Z"
}
```

## Security notes

- **The plugin should never contain AWS access keys.** It talks to AWS exclusively through the public API Gateway endpoint, not the AWS SDK directly.
- If an API secret is used, treat it as a shared application secret (sent via the `x-api-secret` header) — never expose the real value in the plugin's public source or in this repository. Use `YOUR_API_SECRET` as a placeholder.

## Debugging tip: don't confuse this with WooCommerce's native recommendations

WooCommerce ships with its own built-in "related products" behavior, which can easily be mistaken for this plugin's AWS-generated recommendations during testing. When verifying the system end-to-end, confirm that the products shown are actually coming from this custom plugin's logic — clearing the S3 `recommendations.json` file will **not** remove WooCommerce's native related-products display, since that's a separate, unrelated feature.

## Interface contract

- **Sends to:** `POST` on the API Gateway endpoint (`/events`), with the event JSON body and `x-api-secret` header.
- **Reads from:** the recommendations endpoint/output (`recommendations.json`, retrieved via API Gateway or directly from S3 depending on final deployment configuration), keyed by `product_id`.
