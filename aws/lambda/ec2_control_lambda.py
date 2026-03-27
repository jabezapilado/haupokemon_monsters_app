import json
import os

import boto3
from botocore.exceptions import ClientError

AWS_REGION = os.getenv("AWS_REGION", "eu-west-3")
INSTANCE_ID = os.getenv("EC2_INSTANCE_ID", "i-0723af5b19f90de74")


def _response(status_code: int, body: dict) -> dict:
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type, Authorization",
            "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
        },
        "body": json.dumps(body),
    }


def _describe_state(ec2_client):
    result = ec2_client.describe_instances(InstanceIds=[INSTANCE_ID])
    return (
        result.get("Reservations", [{}])[0]
        .get("Instances", [{}])[0]
        .get("State", {})
        .get("Name", "unknown")
    )


def _method(event: dict) -> str:
    return (
        (event.get("requestContext", {}).get("http", {}).get("method"))
        or event.get("httpMethod")
        or ""
    ).upper()


def _path(event: dict) -> str:
    return (
        event.get("rawPath")
        or event.get("path")
        or event.get("resource")
        or ""
    ).lower()


def _action(event: dict) -> str:
    query_params = event.get("queryStringParameters") or {}
    return (query_params.get("action") or "").strip().lower()


def lambda_handler(event, context):
    method = _method(event)
    path = _path(event)
    action = _action(event)

    if method == "OPTIONS":
        return _response(200, {"success": True, "message": "CORS preflight ok"})

    ec2 = boto3.client("ec2", region_name=AWS_REGION)

    try:
        is_status_route = path.endswith("/ec2/status") or action == "status"
        is_start_route = path.endswith("/ec2/start") or action == "start"
        is_stop_route = path.endswith("/ec2/stop") or action == "stop"

        if is_status_route and method == "GET":
            state = _describe_state(ec2)
            return _response(200, {
                "success": True,
                "message": "Status fetched",
                "instance_state": state,
            })

        if is_start_route and method in {"GET", "POST"}:
            result = ec2.start_instances(InstanceIds=[INSTANCE_ID])
            transition = result.get("StartingInstances", [{}])[0]
            return _response(200, {
                "success": True,
                "message": "Start command sent",
                "previous_state": transition.get("PreviousState", {}).get("Name", "unknown"),
                "instance_state": transition.get("CurrentState", {}).get("Name", "pending"),
            })

        if is_stop_route and method in {"GET", "POST"}:
            result = ec2.stop_instances(InstanceIds=[INSTANCE_ID])
            transition = result.get("StoppingInstances", [{}])[0]
            return _response(200, {
                "success": True,
                "message": "Stop command sent",
                "previous_state": transition.get("PreviousState", {}).get("Name", "unknown"),
                "instance_state": transition.get("CurrentState", {}).get("Name", "stopping"),
            })

        return _response(404, {"success": False, "message": "Route not found"})
    except ClientError as err:
        message = err.response.get("Error", {}).get("Message", str(err))
        return _response(500, {
            "success": False,
            "message": f"EC2 operation failed: {message}",
            "instance_state": "unknown",
        })
    except Exception as err:  # noqa: BLE001
        return _response(500, {
            "success": False,
            "message": f"Unexpected error: {err}",
            "instance_state": "unknown",
        })
