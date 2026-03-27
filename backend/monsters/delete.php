<?php
header("Content-Type: application/json");
include("../config/db.php");

$data = getJsonInput();

$monster_id = $data['monster_id'] ?? ($_POST['monster_id'] ?? '');

if ($monster_id === '') {
    respond(false, "monster_id is required");
}

$stmt = $conn->prepare("DELETE FROM monsterstbl WHERE monster_id = ?");
$stmt->bind_param("i", $monster_id);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        respond(true, "Monster deleted successfully");
    } else {
        respond(true, "Monster not found");
    }
} else {
    respond(false, "Failed to delete monster", ["error" => $conn->error]);
}

$stmt->close();
$conn->close();
?>