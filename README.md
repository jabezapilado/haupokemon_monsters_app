


# HAUPokemon Monster’s App

Project by: Apilado, Jabez Timothy and Quilantang, Grant Mihkael

Multi-platform monster catching app with cloud backend.

---

## Overview
HAUPokemon Monster’s App is a full-stack, cross-platform application for catching monsters, managing players, and competing on leaderboards. Built with Flutter for iOS, Android, Web, and Desktop, and powered by a PHP/MySQL backend on AWS, it features real-time map-based gameplay, secure cloud integration, and robust CRUD operations.

## Main Features
- User registration, login, and password reset
- Player and monster CRUD (create, read, update, delete)
- Map & GPS-based monster catching with custom alarm, flash, and haptics
- Top 10 leaderboard
- EC2 instance control (start/stop/status) from the app
- Environment switching (local/AWS/Tailscale)
- Secure AWS integration (IAM, VPC peering, no hardcoded keys)
- Unified dialog layouts and cross-platform support

See [docs/features-and-descriptions.md](docs/features-and-descriptions.md) for a full feature list and descriptions.

## Tech Stack
- **Flutter (Dart)** for the frontend (mobile, web, desktop)
- **PHP 8+** for backend APIs
- **MySQL** for database
- **AWS EC2, Lambda, API Gateway, IAM, VPC, Tailscale VPN** for cloud infrastructure

## Prerequisites
1. Flutter 3.x or newer
2. PHP 8.x or newer
3. MySQL 8.x or newer
4. AWS account (for cloud deployment)
5. Git (optional, for collaboration)


## App Workflows

### Running Locally
**Backend:**
1. Deploy the `backend/` folder to your local PHP server (e.g., XAMPP, MAMP, or built-in PHP server).
2. Import the database schema from `database/schema.sql` and seed data from `database/seed.sql` into your local MySQL instance.
3. Set your local database credentials in `backend/config/db.php`.

**Frontend:**
1. In the Flutter app, ensure the API endpoints point to your local backend server (e.g., `http://localhost:8000/backend/`).
2. Run `flutter pub get` in the project root.
3. Launch the app on your desired platform.

### Running with Cloud (AWS)
**Backend:**
1. Deploy the `backend/` folder to your AWS EC2 instance (see [backend/README_ec2_setup.md](backend/README_ec2_setup.md)).
2. Import the database schema and seed data into your AWS RDS or EC2-hosted MySQL instance.
3. Set your cloud database credentials in `backend/config/db.php`.
4. (Optional) Set up Tailscale VPN for secure access between app and backend.

**Frontend:**
1. In the Flutter app, update the API endpoints to point to your cloud backend (e.g., your EC2 public DNS or Tailscale IP).
2. Run `flutter pub get` if not already done.
3. Launch the app on your desired platform.

### Switching Environments
- The app supports switching between local and cloud (AWS) environments via a configuration or environment selector in the app (see `lib/config.dart`).
- Update the base API URL in the config to match your target backend.

For more details, see the documentation in the `docs/` and `aws/` folders.

## Sample Usage
- Register a new user and log in.
- Catch monsters using the map interface.
- View and compete on the Top 10 leaderboard.
- Start/stop EC2 backend from the app.

## Project Structure

```text
pokemon-app-main/
├── android/
├── ios/
├── web/
├── linux/
├── macos/
├── windows/
├── lib/
│   ├── main.dart
│   ├── config.dart
│   ├── screens/
│   │   ├── auth/
│   │   ├── catch/
│   │   ├── ec2/
│   │   ├── leaderboard/
│   │   ├── monsters/
│   │   └── players/
│   ├── services/
│   ├── utils/
│   └── widgets/
├── backend/
│   ├── config/
│   │   └── db.php
│   ├── auth/       
│   │   ├── login.php
│   │   └── register.php
│   ├── players/
│   │   ├── create.php
│   │   ├── read.php
│   │   ├── update.php
│   │   └── delete.php
│   ├── monsters/
│   │   ├── create.php
│   │   ├── read.php
│   │   ├── update.php
│   │   ├── delete.php
│   │   └── upload_image.php
│   ├── catch/
│   │   └── catch_monster.php
│   ├── leaderboard/
│   │   └── top10.php
│   ├── ec2/
│   │   ├── start.php
│   │   ├── stop.php
│   │   └── status.php
│   ├── composer.json
│   └── README_ec2_setup.md
├── database/
│   ├── schema.sql
│   ├── locationstbl.sql
│   └── seed.sql
├── docs/
│   ├── api_examples_and_navigation.md
│   ├── network-diagram.png
│   ├── pricing-estimate.pdf
│   ├── task-list.pdf
│   └── demo-script.md
├── aws/
│   ├── architecture-notes.md
│   ├── iam-viewer-details.txt
│   ├── lambda/
│   ├── cloudwatch/
│   └── screenshots/
├── demo/
├── test/
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## Contributors
- Apilado, Jabez Timothy — Full-stack, backend, AWS integration
- Quilantang, Grant Mihkael — Frontend, UI/UX, integration

## Team Grouping and Roles
- **Full-stack/Backend:** Jabez Timothy Apilado
- **Frontend/UI:** Grant Mihkael Quilantang

## Notes
- All core features are integrated into a single cross-platform app.
- Cloud backend can be switched between local and AWS environments.
- Secure AWS practices: IAM roles, no hardcoded secrets, VPC peering.


## References
- Flutter Documentation: https://docs.flutter.dev/
- AWS Documentation: https://docs.aws.amazon.com/
- PHP Manual: https://www.php.net/manual/en/
- MySQL Documentation: https://dev.mysql.com/doc/
- Tailscale Documentation: https://tailscale.com/kb/

## License
This project is released for educational use. Apply additional licensing as needed before redistribution.
