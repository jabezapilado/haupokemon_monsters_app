<?php
header("Content-Type: application/json");
include("../config/db.php");

$data = getJsonInput();

$player_id = $data['player_id'] ?? ($_POST['player_id'] ?? '');

if ($player_id === '') {
    respond(false, "player_id is required");
}

$stmt = $conn->prepare("DELETE FROM playerstbl WHERE player_id = ?");
$stmt->bind_param("i", $player_id);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        respond(true, "Player deleted successfully");
    } else {
        respond(true, "Player not found");
    }
} else {
    respond(false, "Failed to delete player", ["error" => $conn->error]);
}

$stmt->close();
$conn->close();
?>