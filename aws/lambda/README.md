# EC2 Control Lambda + API Gateway

This Lambda lets the mobile app control EC2 without depending on the same web server instance staying online.

## 1) Create Lambda

1. Runtime: Python 3.12
2. Handler: `ec2_control_lambda.lambda_handler`
3. Environment variables:
   - `AWS_REGION=eu-west-3`
   - `EC2_INSTANCE_ID=i-0723af5b19f90de74`

## 2) Lambda IAM Role Policy (minimum)

Use this policy (replace region/account if needed):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      "Resource": "arn:aws:ec2:eu-west-3:*:instance/i-0723af5b19f90de74"
    },
    {
      "Effect": "Allow",
      "Action": "ec2:DescribeInstances",
      "Resource": "*"
    }
  ]
}
```

## 3) API Gateway (HTTP API)

Create routes and integrate all with this Lambda:

- `GET /ec2/status`
- `POST /ec2/start`
- `POST /ec2/stop`
- `OPTIONS /ec2/{proxy+}` (optional, if you manage CORS manually)

Enable CORS for your app origins (or `*` for testing).

## 4) Test with curl

Replace `YOUR_API_ID` and stage:

```bash
curl -i https://YOUR_API_ID.execute-api.eu-west-3.amazonaws.com/prod/ec2/status
curl -i -X POST https://YOUR_API_ID.execute-api.eu-west-3.amazonaws.com/prod/ec2/start
curl -i -X POST https://YOUR_API_ID.execute-api.eu-west-3.amazonaws.com/prod/ec2/stop
```

## 5) App config

In `lib/config.dart`:

- `useLambdaEc2Control = true`
- `lambdaEc2ControlBaseUrl = 'https://YOUR_API_ID.execute-api.eu-west-3.amazonaws.com/prod'`

EC2 control in the app will call API Gateway routes instead of `/api/ec2/*.php`.
