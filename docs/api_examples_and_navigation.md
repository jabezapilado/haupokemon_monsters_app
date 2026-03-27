Pokemon App API Examples and Navigation

Base URL format
- http://YOUR_EC2_PUBLIC_IP_OR_DOMAIN/api

Feature A: Player accounts and Players CRUD

Navigation flow
- Login Screen -> Home Screen
- Register Screen -> back to Login Screen
- Home Screen -> Player List
- Player List -> Edit Player
- Player List -> Delete Player confirmation dialog

A1) auth/register.php
Request JSON
{
  "player_name": "Ash",
  "email": "ash@example.com",
  "password": "123456"
}
Response JSON (success)
{
  "success": true,
  "message": "Registration successful",
  "player_id": 5
}

A2) auth/login.php
Request JSON
{
  "email": "ash@example.com",
  "password": "123456"
}
Response JSON (success)
{
  "success": true,
  "message": "Login successful",
  "player": {
    "player_id": 5,
    "player_name": "Ash",
    "email": "ash@example.com"
  }
}

A3) players/read.php
Response JSON
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

A4) players/update.php
Request JSON
{
  "player_id": 5,
  "player_name": "Ash K",
  "email": "ashk@example.com",
  "new_password": "7890"
}
Response JSON
{
  "success": true,
  "message": "Player updated"
}

A5) players/delete.php
Request JSON
{
  "player_id": 5
}
Response JSON
{
  "success": true,
  "message": "Player deleted"
}

Feature B: Monsters CRUD

Navigation flow
- Home Screen -> Monster List
- Monster List -> Add Monster
- Monster List -> Edit Monster
- Monster List -> Delete Monster

B1) monsters/create.php
Request JSON
{
  "monster_name": "Pikachu",
  "type": "Electric",
  "latitude": 13.7563,
  "longitude": 100.5018,
  "radius": 80,
  "picture": "https://example.com/pikachu.png"
}
Response JSON
{
  "success": true,
  "message": "Monster created",
  "monster_id": 9
}

B2) monsters/read.php
Response JSON
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

B3) monsters/update.php
Request JSON
{
  "monster_id": 9,
  "monster_name": "Pikachu",
  "type": "Electric",
  "latitude": 13.7563,
  "longitude": 100.5018,
  "radius": 120,
  "picture": "https://example.com/pikachu.png"
}
Response JSON
{
  "success": true,
  "message": "Monster updated"
}

B4) monsters/delete.php
Request JSON
{
  "monster_id": 9
}
Response JSON
{
  "success": true,
  "message": "Monster deleted"
}

Image upload note
- Current code uses picture URL string in field picture.
- Later, you can add multipart upload endpoint and store uploaded file path in picture.

Feature C: Catch Monsters

Navigation flow
- Home Screen -> Catch Monster
- Catch Monster button -> get GPS -> call catch/catch_monster.php -> show result

C1) catch/catch_monster.php
Request JSON
{
  "player_id": 1,
  "latitude": 13.7563,
  "longitude": 100.5018
}
Response JSON (found)
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
Response JSON (no monster)
{
  "success": true,
  "message": "No monster found nearby",
  "found": false
}
Response JSON (duplicate)
{
  "success": true,
  "message": "Monster already caught before",
  "found": false,
  "duplicate": true
}

Feature D: Top 10 leaderboard

Navigation flow
- Home Screen -> Leaderboard

D1) leaderboard/top10.php
Response JSON
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

Feature E: EC2 automation and monitoring

Navigation flow
- Home Screen -> EC2 Control
- EC2 Control -> Start Instance / Stop Instance / Refresh Status

E1) ec2/start.php
Response JSON
{
  "success": true,
  "message": "Start command sent"
}

E2) ec2/stop.php
Response JSON
{
  "success": true,
  "message": "Stop command sent"
}

E3) ec2/status.php
Response JSON
{
  "success": true,
  "message": "Status fetched",
  "instance_state": "running"
}
