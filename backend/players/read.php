<?php
require_once __DIR__ . '/../config/db.php';

$sql = 'SELECT player_id, player_name, username FROM playerstbl ORDER BY player_id DESC';
$result = $conn->query($sql);

$players = [];
while ($row = $result->fetch_assoc()) {
    $players[] = $row;
}

respond(true, 'Players fetched', ['players' => $players]);
?>
