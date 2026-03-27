-- Use this for new setup or compare with existing tables.

CREATE DATABASE IF NOT EXISTS haumonstersDB;
USE haumonstersDB;

CREATE TABLE IF NOT EXISTS playerstbl (
  player_id INT AUTO_INCREMENT PRIMARY KEY,
  player_name VARCHAR(100) NOT NULL,
  username VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS monsterstbl (
  monster_id INT AUTO_INCREMENT PRIMARY KEY,
  monster_name VARCHAR(100) NOT NULL,
  monster_type VARCHAR(50) NOT NULL,
  spawn_latitude DECIMAL(10, 7) NOT NULL,
  spawn_longitude DECIMAL(10, 7) NOT NULL,
  spawn_radius_meters DECIMAL(10, 2) NOT NULL,
  picture_url VARCHAR(255) DEFAULT '',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS monster_catchestbl (
  catch_id INT AUTO_INCREMENT PRIMARY KEY,
  player_id INT NOT NULL,
  monster_id INT NOT NULL,
  latitude DECIMAL(10, 7) NULL,
  longitude DECIMAL(10, 7) NULL,
  caught_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY unique_player_monster (player_id, monster_id),
  CONSTRAINT fk_catches_player FOREIGN KEY (player_id) REFERENCES playerstbl(player_id) ON DELETE CASCADE,
  CONSTRAINT fk_catches_monster FOREIGN KEY (monster_id) REFERENCES monsterstbl(monster_id) ON DELETE CASCADE
);

-- If your tables already exist, run only missing changes:
-- ALTER TABLE playerstbl ADD COLUMN username VARCHAR(100) UNIQUE;
-- ALTER TABLE playerstbl ADD COLUMN password VARCHAR(255) NOT NULL;
-- ALTER TABLE monsterstbl ADD COLUMN monster_type VARCHAR(50) NOT NULL;
-- ALTER TABLE monsterstbl ADD COLUMN spawn_latitude DECIMAL(10,7) NOT NULL;
-- ALTER TABLE monsterstbl ADD COLUMN spawn_longitude DECIMAL(10,7) NOT NULL;
-- ALTER TABLE monsterstbl ADD COLUMN spawn_radius_meters DECIMAL(10,2) NOT NULL;
-- ALTER TABLE monsterstbl ADD COLUMN picture_url VARCHAR(255) DEFAULT '';
-- ALTER TABLE monster_catchestbl ADD COLUMN caught_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP;
-- ALTER TABLE monster_catchestbl ADD COLUMN latitude DECIMAL(10,7) NULL;
-- ALTER TABLE monster_catchestbl ADD COLUMN longitude DECIMAL(10,7) NULL;
-- ALTER TABLE monster_catchestbl ADD UNIQUE KEY unique_player_monster (player_id, monster_id);
