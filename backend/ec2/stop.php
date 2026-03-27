<?php
require_once __DIR__ . '/ec2_config.php';

use Aws\Exception\AwsException;

try {
    $ec2 = getEc2Client();
    $instanceId = getEc2InstanceId();

    $result = $ec2->stopInstances([
        'InstanceIds' => [$instanceId]
    ]);

    $transition = $result['StoppingInstances'][0] ?? [];

    respond(true, 'Stop command sent', [
        'previous_state' => $transition['PreviousState']['Name'] ?? 'unknown',
        'instance_state' => $transition['CurrentState']['Name'] ?? 'stopping',
    ]);
} catch (AwsException $e) {
    respond(false, 'EC2 stop failed: ' . $e->getAwsErrorMessage(), [
        'instance_state' => 'unknown'
    ]);
} catch (Throwable $e) {
    respond(false, 'EC2 stop failed: ' . $e->getMessage(), [
        'instance_state' => 'unknown'
    ]);
}
?>