<?php
header("Content-Type: application/json");
include("../config/db.php");

$data = getJsonInput();

$player_name = trim($data['player_name'] ?? ($_POST['player_name'] ?? ''));
$username = trim($data['username'] ?? ($_POST['username'] ?? ''));
$new_password = $data['new_password'] ?? ($_POST['new_password'] ?? '');

if ($player_name === '' || $username === '' || $new_password === '') {
    respond(false, 'player_name, username, and new_password are required');
}

if (strlen($new_password) < 6) {
    respond(false, 'New password must be at least 6 characters');
}

$stmt = $conn->prepare("SELECT player_id FROM playerstbl WHERE username = ? AND player_name = ? LIMIT 1");
$stmt->bind_param("ss", $username, $player_name);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    respond(false, 'Account not found. Check player name and username.');
}

$player = $result->fetch_assoc();
$player_id = (int)$player['player_id'];
$hashed_password = password_hash($new_password, PASSWORD_DEFAULT);

$update = $conn->prepare("UPDATE playerstbl SET password = ? WHERE player_id = ?");
$update->bind_param("si", $hashed_password, $player_id);

if ($update->execute()) {
    respond(true, 'Password reset successful. You can now log in.');
}

respond(false, 'Failed to reset password', ['error' => $conn->error]);
?>
