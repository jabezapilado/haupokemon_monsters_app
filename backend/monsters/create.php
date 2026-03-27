<?php
header("Content-Type: application/json");
include("../config/db.php");

$data = getJsonInput();

$monster_name = $data['monster_name'] ?? ($_POST['monster_name'] ?? '');
$monster_type = $data['monster_type'] ?? ($_POST['monster_type'] ?? '');
$spawn_latitude = $data['spawn_latitude'] ?? ($_POST['spawn_latitude'] ?? '');
$spawn_longitude = $data['spawn_longitude'] ?? ($_POST['spawn_longitude'] ?? '');
$spawn_radius_meters = $data['spawn_radius_meters'] ?? ($_POST['spawn_radius_meters'] ?? '');
$picture_url = $data['picture_url'] ?? ($_POST['picture_url'] ?? '');

if (
    $monster_name === '' ||
    $monster_type === '' ||
    $spawn_latitude === '' ||
    $spawn_longitude === '' ||
    $spawn_radius_meters === ''
) {
    respond(false, "monster_name, monster_type, spawn_latitude, spawn_longitude, and spawn_radius_meters are required");
}

$stmt = $conn->prepare("
    INSERT INTO monsterstbl
    (monster_name, monster_type, spawn_latitude, spawn_longitude, spawn_radius_meters, picture_url)
    VALUES (?, ?, ?, ?, ?, ?)
");
$stmt->bind_param(
    "ssddds",
    $monster_name,
    $monster_type,
    $spawn_latitude,
    $spawn_longitude,
    $spawn_radius_meters,
    $picture_url
);

if ($stmt->execute()) {
    respond(true, "Monster created successfully", [
        "monster_id" => $conn->insert_id
    ]);
} else {
    respond(false, "Failed to create monster", ["error" => $conn->error]);
}

$stmt->close();
$conn->close();
?>