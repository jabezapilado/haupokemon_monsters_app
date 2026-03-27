<?php
header("Content-Type: application/json");
include("../config/db.php");

$data = getJsonInput();

$monster_id = $data['monster_id'] ?? ($_POST['monster_id'] ?? '');
$monster_name = $data['monster_name'] ?? ($_POST['monster_name'] ?? '');
$monster_type = $data['monster_type'] ?? ($_POST['monster_type'] ?? '');
$spawn_latitude = $data['spawn_latitude'] ?? ($_POST['spawn_latitude'] ?? '');
$spawn_longitude = $data['spawn_longitude'] ?? ($_POST['spawn_longitude'] ?? '');
$spawn_radius_meters = $data['spawn_radius_meters'] ?? ($_POST['spawn_radius_meters'] ?? '');
$picture_url = $data['picture_url'] ?? ($_POST['picture_url'] ?? '');

if (
    $monster_id === '' ||
    $monster_name === '' ||
    $monster_type === '' ||
    $spawn_latitude === '' ||
    $spawn_longitude === '' ||
    $spawn_radius_meters === ''
) {
    respond(false, "monster_id, monster_name, monster_type, spawn_latitude, spawn_longitude, and spawn_radius_meters are required");
}

$stmt = $conn->prepare("
    UPDATE monsterstbl
    SET monster_name = ?, monster_type = ?, spawn_latitude = ?, spawn_longitude = ?, spawn_radius_meters = ?, picture_url = ?
    WHERE monster_id = ?
");

$stmt->bind_param(
    "ssdddsi",
    $monster_name,
    $monster_type,
    $spawn_latitude,
    $spawn_longitude,
    $spawn_radius_meters,
    $picture_url,
    $monster_id
);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        respond(true, "Monster updated successfully");
    } else {
        respond(true, "No changes made or monster not found");
    }
} else {
    respond(false, "Failed to update monster", ["error" => $conn->error]);
}

$stmt->close();
$conn->close();
?>