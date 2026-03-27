<?php
header("Content-Type: application/json");
include("../config/db.php");

$data = getJsonInput();

$player_name = $data['player_name'] ?? ($_POST['player_name'] ?? '');
$username = $data['username'] ?? ($_POST['username'] ?? '');
$password = $data['password'] ?? ($_POST['password'] ?? '');

if ($player_name === '' || $username === '' || $password === '') {
    respond(false, "player_name, username, and password are required");
}

$hashedPassword = password_hash($password, PASSWORD_DEFAULT);

$stmt = $conn->prepare("INSERT INTO playerstbl (player_name, username, password) VALUES (?, ?, ?)");
$stmt->bind_param("sss", $player_name, $username, $hashedPassword);

if ($stmt->execute()) {
    respond(true, "Player created successfully", [
        "player_id" => $conn->insert_id
    ]);
} else {
    respond(false, "Failed to create player", ["error" => $conn->error]);
}

$stmt->close();
$conn->close();
?>