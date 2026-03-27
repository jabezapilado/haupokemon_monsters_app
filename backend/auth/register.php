<?php
require_once __DIR__ . '/../config/db.php';

$data = getJsonInput();
$player_name = trim($data['player_name'] ?? '');
$username = trim($data['username'] ?? '');
$password = $data['password'] ?? '';

if ($player_name === '' || $username === '' || $password === '') {
    respond(false, 'All fields are required');
}

$check = $conn->prepare('SELECT player_id FROM playerstbl WHERE username = ?');
$check->bind_param('s', $username);
$check->execute();
$exists = $check->get_result();
if ($exists->num_rows > 0) {
    respond(false, 'Username already registered');
}

$hashed_password = password_hash($password, PASSWORD_DEFAULT);
$stmt = $conn->prepare('INSERT INTO playerstbl (player_name, username, password) VALUES (?, ?, ?)');
$stmt->bind_param('sss', $player_name, $username, $hashed_password);

if ($stmt->execute()) {
    respond(true, 'Registration successful', ['player_id' => $conn->insert_id]);
}

respond(false, 'Registration failed');
?>
