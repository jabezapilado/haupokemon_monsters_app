USE haumonstersDB;

CREATE TABLE IF NOT EXISTS locationstbl (
  location_id INT AUTO_INCREMENT PRIMARY KEY,
  monster_id INT NOT NULL,
  latitude DECIMAL(10,7) NOT NULL,
  longitude DECIMAL(10,7) NOT NULL,
  FOREIGN KEY (monster_id) REFERENCES monsterstbl(monster_id) ON DELETE CASCADE
);