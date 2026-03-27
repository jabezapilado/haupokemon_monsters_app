<?php
header("Content-Type: application/json");
include("../config/db.php");

$data = getJsonInput();

$player_id = $data['player_id'] ?? ($_POST['player_id'] ?? '');
$monster_id = $data['monster_id'] ?? ($_POST['monster_id'] ?? '');
$latitude = $data['latitude'] ?? ($_POST['latitude'] ?? null);
$longitude = $data['longitude'] ?? ($_POST['longitude'] ?? null);

if ($player_id === '' || $monster_id === '') {
    respond(false, "player_id and monster_id are required");
}

$checkPlayer = $conn->prepare("SELECT player_id FROM playerstbl WHERE player_id = ?");
$checkPlayer->bind_param("i", $player_id);
$checkPlayer->execute();
$playerResult = $checkPlayer->get_result();

if ($playerResult->num_rows === 0) {
    respond(false, "Player not found");
}

$checkMonster = $conn->prepare("SELECT monster_id FROM monsterstbl WHERE monster_id = ?");
$checkMonster->bind_param("i", $monster_id);
$checkMonster->execute();
$monsterResult = $checkMonster->get_result();

if ($monsterResult->num_rows === 0) {
    respond(false, "Monster not found");
}

$checkCatch = $conn->prepare("SELECT catch_id FROM monster_catchestbl WHERE player_id = ? AND monster_id = ?");
$checkCatch->bind_param("ii", $player_id, $monster_id);
$checkCatch->execute();
$catchResult = $checkCatch->get_result();

if ($catchResult->num_rows > 0) {
    respond(false, "Monster already caught by this player");
}

$conn->query("
    CREATE TABLE IF NOT EXISTS player_catch_totals (
        player_id INT PRIMARY KEY,
        total_catches INT NOT NULL DEFAULT 0,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        CONSTRAINT fk_totals_player FOREIGN KEY (player_id)
            REFERENCES playerstbl(player_id) ON DELETE CASCADE
    )
");

$stmt = $conn->prepare("
    INSERT INTO monster_catchestbl (player_id, monster_id, latitude, longitude)
    VALUES (?, ?, ?, ?)
");
$stmt->bind_param("iidd", $player_id, $monster_id, $latitude, $longitude);

$conn->begin_transaction();

if ($stmt->execute()) {
    $catchId = $conn->insert_id;

    $statsStmt = $conn->prepare("
        INSERT INTO player_catch_totals (player_id, total_catches)
        VALUES (?, 1)
        ON DUPLICATE KEY UPDATE total_catches = total_catches + 1
    ");
    $statsStmt->bind_param("i", $player_id);

    if ($statsStmt->execute()) {
        $conn->commit();
        respond(true, "Monster caught successfully", [
            "catch_id" => $catchId
        ]);
    }

    $conn->rollback();
    respond(false, "Failed to update leaderboard stats", ["error" => $conn->error]);
}

$conn->rollback();
respond(false, "Failed to catch monster", ["error" => $conn->error]);
?>
