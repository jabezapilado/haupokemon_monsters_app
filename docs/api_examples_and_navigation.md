# API Examples and Navigation

## Base URL

```text
http://YOUR_EC2_PUBLIC_IP_OR_DOMAIN/api
```

## A) Player Accounts and Players CRUD

### Navigation Flow
- `Login Screen` -> `Home Screen`
- `Register Screen` -> back to `Login Screen`
- `Home Screen` -> `Player List`
- `Player List` -> `Edit Player`
- `Player List` -> `Delete Player` confirmation dialog

### Endpoints

#### `auth/register.php`
Request:
```json
{
  "player_name": "Ash",
  "email": "ash@example.com",
  "password": "123456"
}
```

Response (success):
```json
{
  "success": true,
  "message": "Registration successful",
  "player_id": 5
}
```

#### `auth/login.php`
Request:
```json
{
  "email": "ash@example.com",
  "password": "123456"
}
```

Response (success):
```json
{
  "success": true,
  "message": "Login successful",
  "player": {
    "player_id": 5,
    "player_name": "Ash",
    "email": "ash@example.com"
  }
}
```

#### `players/read.php`
Response:
```json
{
  "success": true,
  "message": "Players fetched",
  "players": [
    {
      "player_id": "5",
      "player_name": "Ash",
      "email": "ash@example.com"
    }
  ]
}
```

#### `players/update.php`
Request:
```json
{
  "player_id": 5,
  "player_name": "Ash K",
  "email": "ashk@example.com",
  "new_password": "7890"
}
```

Response:
```json
{
  "success": true,
  "message": "Player updated"
}
```

#### `players/delete.php`
Request:
```json
{
  "player_id": 5
}
```

Response:
```json
{
  "success": true,
  "message": "Player deleted"
}
```

## B) Monsters CRUD

### Navigation Flow
- `Home Screen` -> `Monster List`
- `Monster List` -> `Add Monster`
- `Monster List` -> `Edit Monster`
- `Monster List` -> `Delete Monster`

### Endpoints

#### `monsters/create.php`
Request:
```json
{
  "monster_name": "Pikachu",
  "type": "Electric",
  "latitude": 13.7563,
  "longitude": 100.5018,
  "radius": 80,
  "picture": "https://example.com/pikachu.png"
}
```

Response:
```json
{
  "success": true,
  "message": "Monster created",
  "monster_id": 9
}
```

#### `monsters/read.php`
Response:
```json
{
  "success": true,
  "message": "Monsters fetched",
  "monsters": [
    {
      "monster_id": "9",
      "monster_name": "Pikachu",
      "type": "Electric",
      "latitude": "13.7563000",
      "longitude": "100.5018000",
      "radius": "80.00",
      "picture": "https://example.com/pikachu.png"
    }
  ]
}
```

#### `monsters/update.php`
Request:
```json
{
  "monster_id": 9,
  "monster_name": "Pikachu",
  "type": "Electric",
  "latitude": 13.7563,
  "longitude": 100.5018,
  "radius": 120,
  "picture": "https://example.com/pikachu.png"
}
```

Response:
```json
{
  "success": true,
  "message": "Monster updated"
}
```

#### `monsters/delete.php`
Request:
```json
{
  "monster_id": 9
}
```

Response:
```json
{
  "success": true,
  "message": "Monster deleted"
}
```

### Image Upload Note
- Current implementation uses a `picture` URL string.
- You can later add a multipart upload endpoint and store file paths in `picture`.

## C) Catch Monsters

### Navigation Flow
- `Home Screen` -> `Catch Monster`
- Tap catch button -> read GPS -> call `catch/catch_monster.php` -> show result

### Endpoint

#### `catch/catch_monster.php`
Request:
```json
{
  "player_id": 1,
  "latitude": 13.7563,
  "longitude": 100.5018
}
```

Response (found):
```json
{
  "success": true,
  "message": "Monster caught successfully",
  "found": true,
  "distance_meters": 23.17,
  "monster": {
    "monster_id": "9",
    "monster_name": "Pikachu",
    "type": "Electric",
    "latitude": "13.7563000",
    "longitude": "100.5018000",
    "radius": "80.00",
    "picture": "https://example.com/pikachu.png"
  }
}
```

Response (no monster):
```json
{
  "success": true,
  "message": "No monster found nearby",
  "found": false
}
```

Response (duplicate):
```json
{
  "success": true,
  "message": "Monster already caught before",
  "found": false,
  "duplicate": true
}
```

## D) Top 10 Leaderboard

### Navigation Flow
- `Home Screen` -> `Leaderboard`

### Endpoint

#### `leaderboard/top10.php`
Response:
```json
{
  "success": true,
  "message": "Leaderboard fetched",
  "leaderboard": [
    {
      "rank": 1,
      "player_id": 1,
      "player_name": "Ash",
      "total_catches": 12
    }
  ]
}
```

## E) EC2 Automation and Monitoring

### Navigation Flow
- `Home Screen` -> `EC2 Control`
- `EC2 Control` -> Start / Stop / Refresh status

### Endpoints

#### `ec2/start.php`
Response:
```json
{
  "success": true,
  "message": "Start command sent"
}
```

#### `ec2/stop.php`
Response:
```json
{
  "success": true,
  "message": "Stop command sent"
}
```

#### `ec2/status.php`
Response:
```json
{
  "success": true,
  "message": "Status fetched",
  "instance_state": "running"
}
```
