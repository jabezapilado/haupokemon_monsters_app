<?php
header("Content-Type: application/json");
include("../config/db.php");

$data = getJsonInput();

$player_id = $data['player_id'] ?? ($_POST['player_id'] ?? '');
$player_name = $data['player_name'] ?? ($_POST['player_name'] ?? '');
$username = $data['username'] ?? ($_POST['username'] ?? '');
$password = $data['password'] ?? ($_POST['password'] ?? '');

if ($player_id === '' || $player_name === '' || $username === '' || $password === '') {
    respond(false, "player_id, player_name, username, and password are required");
}

$hashedPassword = password_hash($password, PASSWORD_DEFAULT);

$stmt = $conn->prepare("UPDATE playerstbl SET player_name = ?, username = ?, password = ? WHERE player_id = ?");
$stmt->bind_param("sssi", $player_name, $username, $hashedPassword, $player_id);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        respond(true, "Player updated successfully");
    } else {
        respond(true, "No changes made or player not found");
    }
} else {
    respond(false, "Failed to update player", ["error" => $conn->error]);
}

$stmt->close();
$conn->close();
?>