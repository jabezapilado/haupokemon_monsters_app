<?php
require_once __DIR__ . '/ec2_config.php';

use Aws\Exception\AwsException;

try {
    $ec2 = getEc2Client();
    $instanceId = getEc2InstanceId();

    $result = $ec2->describeInstances([
        'InstanceIds' => [$instanceId]
    ]);

    $state =
        $result['Reservations'][0]['Instances'][0]['State']['Name']
        ?? 'unknown';

    respond(true, 'Status fetched', [
        'instance_state' => $state
    ]);
} catch (AwsException $e) {
    respond(false, 'EC2 status failed: ' . $e->getAwsErrorMessage(), [
        'instance_state' => 'unknown'
    ]);
} catch (Throwable $e) {
    respond(false, 'EC2 status failed: ' . $e->getMessage(), [
        'instance_state' => 'unknown'
    ]);
}
?>