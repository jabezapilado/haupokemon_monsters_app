<?php
header("Content-Type: application/json");
include("../config/db.php");

$data = getJsonInput();

$username = trim($data['username'] ?? ($_POST['username'] ?? ''));
$password = $data['password'] ?? ($_POST['password'] ?? '');

if ($username === '' || $password === '') {
    respond(false, 'Username and password are required');
}

$stmt = $conn->prepare("SELECT player_id, player_name, username, password FROM playerstbl WHERE username = ? LIMIT 1");
$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 0) {
    respond(false, 'Invalid username or password');
}

$player = $result->fetch_assoc();
$storedPassword = $player['password'];

// Accept both hashed and plain-text passwords for now
$isValid =
    password_verify($password, $storedPassword) ||
    $password === $storedPassword;

if (!$isValid) {
    respond(false, 'Invalid username or password');
}

respond(true, 'Login successful', [
    'player' => [
        'player_id' => (int)$player['player_id'],
        'player_name' => $player['player_name'],
        'username' => $player['username']
    ]
]);
?>