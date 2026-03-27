<?php
header("Content-Type: application/json");
include("../config/db.php");

$sql = "SELECT * FROM monsterstbl ORDER BY monster_id DESC";
$result = $conn->query($sql);

$monsters = [];

if ($result) {
    while ($row = $result->fetch_assoc()) {
        $monsters[] = $row;
    }
}

respond(true, "Monsters fetched", ["monsters" => $monsters]);
?>