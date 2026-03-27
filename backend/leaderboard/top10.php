<?php
header("Content-Type: application/json");
include("../config/db.php");

$conn->query("
    CREATE TABLE IF NOT EXISTS player_catch_totals (
        player_id INT PRIMARY KEY,
        total_catches INT NOT NULL DEFAULT 0,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        CONSTRAINT fk_totals_player FOREIGN KEY (player_id)
            REFERENCES playerstbl(player_id) ON DELETE CASCADE
    )
");

// Backfill totals from current catches for players without saved totals.
// GREATEST keeps the highest-ever total and prevents score drops after monster deletions.
$conn->query("
    INSERT INTO player_catch_totals (player_id, total_catches)
    SELECT player_id, COUNT(*) AS live_catches
    FROM monster_catchestbl
    GROUP BY player_id
    ON DUPLICATE KEY UPDATE total_catches = GREATEST(player_catch_totals.total_catches, VALUES(total_catches))
");

$sql = "
    SELECT
        p.player_id,
        p.player_name,
        p.username,
        COALESCE(pct.total_catches, 0) AS total_catches
    FROM playerstbl p
    LEFT JOIN player_catch_totals pct ON p.player_id = pct.player_id
    ORDER BY total_catches DESC, p.player_name ASC
    LIMIT 10
";

$result = $conn->query($sql);

$leaderboard = [];

if ($result) {
    while ($row = $result->fetch_assoc()) {
        $leaderboard[] = $row;
    }
}

respond(true, "Leaderboard fetched", ["leaderboard" => $leaderboard]);
?>
