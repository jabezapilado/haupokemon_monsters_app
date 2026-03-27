<?php
require_once __DIR__ . '/../vendor/autoload.php';

use Aws\Ec2\Ec2Client;

if (!function_exists('respond')) {
    function respond($success, $message, $extra = []): void
    {
        header('Content-Type: application/json');
        header('Access-Control-Allow-Origin: *');
        header('Access-Control-Allow-Headers: Content-Type, Authorization');
        header('Access-Control-Allow-Methods: GET, POST, OPTIONS');

        echo json_encode(array_merge([
            'success' => $success,
            'message' => $message,
        ], $extra));
        exit;
    }
}

function getEc2Client(): Ec2Client
{
    $region = getenv('AWS_REGION') ?: 'eu-west-3'; // Paris default

    return new Ec2Client([
        'version' => 'latest',
        'region' => $region,
        // Credentials are resolved by the AWS SDK default provider chain.
        // On EC2, attach an IAM role to the instance for secure access.
    ]);
}

function getEc2InstanceId(): string
{
    $instanceId = getenv('EC2_INSTANCE_ID') ?: 'i-0723af5b19f90de74';

    if ($instanceId === '') {
        respond(false, 'EC2 instance ID is not configured', [
            'instance_state' => 'unknown',
        ]);
    }

    return $instanceId;
}
?>