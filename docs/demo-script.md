# Demo Script (Final)

## 1. Intro (15-30 seconds)
- Introduce project: HauPokemon mobile app
- Mention cloud setup:
  - Paris EC2 backend
  - N. Virginia RDS database
  - Lambda/API Gateway for EC2 control
  - Tailscale VPN path

## 2. Show Cloud Readiness
- Open EC2 status in app (or pre-login server gate)
- If server is off, start EC2 from app and wait until running
- Mention this works through Lambda control path

## 3. Authentication Flow
- Register a new account
- Login successfully
- Optional: show forgot password flow

## 4. Player Account
- Open My Account
- Update account details
- Save and verify changes

## 5. Monster Management
- Add a monster with map pin + radius
- Show monster appears in list
- Edit monster details
- Delete a monster

## 6. Catch Flow
- Open catch screen
- Show GPS-based distance/radius check
- Catch a monster
- Confirm catch response
- Show alarm/flashlight behavior if part of demo scenario

## 7. Leaderboard
- Open leaderboard
- Show ranking changes after catches

## 8. EC2 Control
- Open EC2 control page
- Show warning dialog when stopping EC2
- Stop then start EC2 (optional during live demo; do carefully)

## 9. VPN Proof
- Show Tailscale connected on device
- Confirm app requests still work via Tailscale backend URL

## 10. Closing
- Summarize architecture and requirements met
- Mention security improvements:
  - least-privilege IAM
  - env-based DB secrets
  - no hardcoded AWS keys in final path
