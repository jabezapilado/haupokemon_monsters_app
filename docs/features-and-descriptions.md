# Pokémon App – Complete Feature List & Descriptions

## 1. User Authentication
- **Register & Login:** Users can create accounts and log in securely.
  - `lib/screens/players/`, `backend/auth/`

## 2. Player Management (CRUD)
- **Create, View, Edit, Delete Player:** Full management of player profiles.
  - `lib/screens/players/`, `backend/players/`

## 3. Monster Management (CRUD)
- **Create, View, Edit, Delete Monster:** Admins can manage Pokémon/monsters in the system.
  - `lib/screens/monsters/`, `backend/monsters/`

## 4. Catch Pokémon (Core Gameplay)
- **Map & GPS Integration:** Players see their location and nearby monsters on a map.
- **Catch Mechanic:** Tap to catch, with custom alarm (WAV), synchronized flash, haptics, and audio effects.
- **BPM/Onset Sync:** Catch effects are precisely timed to the music’s beat.
- **Effect Overlap Protection:** Prevents multiple catch effects from overlapping.
  - `lib/screens/catch/catch_monster_screen.dart`, `lib/services/`, `lib/utils/`

## 5. Leaderboard
- **Top 10 Players:** Displays the top players based on catches or points.
  - `lib/screens/leaderboard/`, `backend/leaderboard/top10.php`

## 6. Forgot Password
- **Password Reset:** Users can request a password reset if they forget their credentials.
  - `lib/screens/players/forgot_password_screen.dart`, `backend/auth/forgot_password.php`

## 7. Unified Dialogs & UX
- **Consistent Dialog Layouts:** All dialogs (confirmation, errors, delete, etc.) have a unified look and feel.
  - `lib/widgets/`, `lib/screens/players/edit_player_screen.dart`

## 8. Cloud Integration & Backend
- **Backend on AWS EC2 (Paris):** PHP backend is deployed and accessible via cloud.
  - `backend/`, `aws/`, `backend/ec2/`
- **EC2 Control (Start/Stop/Status):** App can remotely control EC2 instance state via Lambda/API Gateway.
  - `backend/ec2/ec2_config.php`, `aws/lambda/`, `aws/architecture-notes.md`
- **Database (MySQL, planned for AWS RDS):** All data stored in MySQL, with migration to RDS planned.
  - `database/`, `backend/config/db.php`
- **Environment Switching:** Easily switch between local, AWS, and Tailscale endpoints.
  - `lib/config.dart`
- **Secure AWS Integration:** IAM roles, VPC peering, and Tailscale VPN for secure cloud access.
  - `aws/iam-viewer-details.txt`, `aws/architecture-notes.md`

## 9. Technical Improvements
- **Cross-Platform Support:** Runs on iOS, Android, Web, macOS, Windows, Linux.
- **Plugin Updates:** Uses latest versions of geolocator, google_maps_flutter, audioplayers, torch_light, shared_preferences, google_fonts.
  - `pubspec.yaml`
- **Code Cleanup:** Removed old build artifacts, improved code structure.
  - `build/`, `lib/`, `android/`, `ios/`
- **Analyzer/Test Clean:** Code passes analyzer and widget tests.
  - `test/`, `lib/`

## 10. Documentation & Deliverables
- **Demo Script:** Step-by-step guide for demonstrating the app.
  - `docs/demo-script.md`
- **API Examples & Navigation:** Sample API calls and navigation flow.
  - `docs/api_examples_and_navigation.md`
- **Architecture Notes:** Cloud and backend architecture details.
  - `aws/architecture-notes.md`
- **IAM Details:** AWS IAM configuration for secure access.
  - `aws/iam-viewer-details.txt`
- **Screenshots:** Visuals for documentation and demo.
  - `aws/screenshots/`
- **Database Schema & Seed:** SQL files for DB structure and sample data.
  - `database/schema.sql`, `database/seed.sql`
- **EC2 Setup Guide:** Instructions for backend deployment.
  - `backend/README_ec2_setup.md`
- **Pricing/Network Diagrams:** Cost and network architecture documentation.
  - `docs/`, `aws/`
