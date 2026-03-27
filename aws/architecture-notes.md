# AWS Architecture Notes

## Regions
- App/Web backend: `eu-west-3` (Paris) EC2
- Database: `us-east-1` (N. Virginia) RDS MySQL
- EC2 control API: API Gateway + Lambda in `eu-west-3`

## Core Components
- **EC2 (Paris)** hosts Apache + PHP backend at `/var/www/html/api`
- **RDS MySQL (N. Virginia)** hosts `haumonstersDB`
- **API Gateway + Lambda** controls EC2 start/stop/status even if EC2 is down
- **Tailscale** provides VPN-based access path for required testing

## Networking
- VPC peering is configured between Paris VPC and N. Virginia VPC
- Route tables updated on both sides for private CIDR reachability
- RDS Security Group allows MySQL `3306` from Paris VPC CIDR

## Security Controls
- Backend DB credentials are read from environment variables (`DB_HOST`, `DB_USER`, `DB_PASS`, `DB_NAME`)
- Lambda/EC2 control uses least-privilege IAM permissions (`DescribeInstances`, `StartInstances`, `StopInstances`)
- Hardcoded AWS credentials are not used in final control flow

## Runtime Notes
- If EC2 is stopped, backend API features are unavailable until EC2 is started
- EC2 can still be started via Lambda control path
- App includes pre-login server availability gate and EC2 control screen warning

## Verification Endpoints
- Backend status (EC2-hosted): `http://13.39.66.13/api/ec2/status.php`
- Lambda status: `https://5yjbyofkjk.execute-api.eu-west-3.amazonaws.com/HauPokemon_Lambda_Stage/ec2/status`
