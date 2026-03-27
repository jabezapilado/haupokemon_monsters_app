EC2 PHP Setup

This backend uses shared EC2 config from `ec2/ec2_config.php`.

## 1) Install dependencies

From the `backend/` folder:

```bash
composer install
```

This installs `aws/aws-sdk-php` (see `composer.json`).

## 2) Configure runtime values

`ec2/ec2_config.php` reads configuration from environment variables:

- `AWS_REGION` (optional, defaults to `eu-west-3`)
- `EC2_INSTANCE_ID` (optional, defaults to your Paris instance)

No hardcoded AWS access key/secret is required in code.
The AWS SDK resolves credentials using the default provider chain
(recommended: IAM role attached to the EC2 web server).

The endpoint files (`ec2/start.php`, `ec2/stop.php`, `ec2/status.php`) already call:

- `getEc2Client()`
- `getEc2InstanceId()`
- `respond(...)`

## 3) Endpoint behavior

- `ec2/start.php` starts the configured instance and returns:
  - `success`, `message`, `previous_state`, `instance_state`
- `ec2/stop.php` stops the configured instance and returns:
  - `success`, `message`, `previous_state`, `instance_state`
- `ec2/status.php` describes the configured instance and returns:
  - `success`, `message`, `instance_state`

Recommended calls:

- `POST ec2/start.php`
- `POST ec2/stop.php`
- `GET ec2/status.php`

## 4) Security recommendations (important)

- Attach an IAM role to the Paris web server with only:
  - `ec2:StartInstances`
  - `ec2:StopInstances`
  - `ec2:DescribeInstances`
- Scope permissions to the required instance ID whenever possible.
- Keep `AWS_REGION` and `EC2_INSTANCE_ID` in environment variables.
- Do not commit AWS keys/secrets to source control.
- Use a non-production test instance for this feature.
- If any real AWS keys were committed to source, rotate/revoke them immediately.
