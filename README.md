
# Terraform GCP Multi-Environment Project

## Project Structure
```
terraform-gcp-project/
├── Dockerfile
├── docker-compose.yml
├── staging/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   ├── staging-cloud-sql.tf
│   ├── staging-cloud-run.tf
│   ├── staging-cloud-storage.tf
│   ├── staging-cloud-build.tf
│   ├── staging-secrets.tf
│   └── staging-service-accounts.tf
├── production/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example
│   ├── production-cloud-sql.tf
│   ├── production-cloud-run.tf
│   ├── production-cloud-storage.tf
│   ├── production-cloud-build.tf
│   ├── production-secrets.tf
│   └── production-service-accounts.tf
└── README.md
```

## Prerequisites to Run Terraform

### 1. Google Cloud Setup
- Create two GCP projects: `staging-xxx` and `production-xxx`
- Enable the following APIs in both projects:
  - Cloud SQL Admin API
  - Cloud Run API
  - Cloud Storage API
  - Cloud Build API
  - Secret Manager API
  - IAM Service Account Credentials API
  - Compute Engine API

### 2. Authentication
- Create a service account with the following roles:
  - Cloud SQL Admin
  - Cloud Run Admin
  - Storage Admin
  - Cloud Build Editor
  - Secret Manager Admin
  - Service Account Admin
  - Project IAM Admin
- Download the service account key JSON file
- Set the environment variable: `export GOOGLE_APPLICATION_CREDENTIALS="path/to/your/service-account-key.json"`

### 3. Terraform Installation (if not using Docker)
- Install Terraform CLI (version >= 1.0)
- Install Google Cloud SDK

### 4. Using Docker (Recommended)
- Install Docker and Docker Compose
- All dependencies are included in the provided Dockerfile

## Quick Start with Docker

1. **Build the Docker image:**
```bash
docker-compose build
```

2. **Run Terraform commands:**
```bash
# Initialize staging environment
docker-compose run --rm terraform-staging init

# Plan staging environment
docker-compose run --rm terraform-staging plan

# Apply staging environment
docker-compose run --rm terraform-staging apply

# Initialize production environment
docker-compose run --rm terraform-production init

# Plan production environment
docker-compose run --rm terraform-production plan

# Apply production environment
docker-compose run --rm terraform-production apply
```

## Manual Setup Steps

1. **Configure variables:**
   - Copy `terraform.tfvars.example` to `terraform.tfvars` in both environments
   - Update the values according to your requirements

2. **Initialize Terraform:**
```bash
cd staging
terraform init
cd ../production
terraform init
```

3. **Deploy infrastructure:**
```bash
# Deploy staging
cd staging
terraform plan
terraform apply

# Deploy production
cd production
terraform plan
terraform apply
```

## Important Notes

- Database instances will have public IP access
- Service accounts are created with minimal required permissions
- Secrets are managed through Google Secret Manager
- Cloud Build triggers are configured for CI/CD
- All resources use consistent naming with environment prefixes
- Database passwords are auto-generated and stored in Secret Manager

## Environment Variables

The following environment variables will be automatically configured in Cloud Run:
- Application settings (APP_NAME, APP_ENV, APP_KEY, etc.)
- Database connection details
- Google Cloud service configurations
- Third-party service credentials (stored as secrets)

## Security Considerations

- **Least Privilege IAM**: All service accounts follow least privilege principles
- **No Public Access**: Cloud Run services are secured (public access commented out)
- **Production Hardening**: Debug mode disabled, comprehensive monitoring enabled
- **Monitoring & Alerting**: Full monitoring stack with email notifications
- **Secret Management**: Secure handling through Google Secret Manager
- Update default passwords and secrets before production deployment
- Review IAM permissions and adjust as needed
- Configure email addresses for monitoring alerts
- See [SECURITY.md](SECURITY.md) for detailed security implementation guide

## Monitoring and Alerting

This infrastructure includes comprehensive monitoring:

### Production Monitoring:
- Uptime checks every 60 seconds
- Error rate monitoring with immediate alerts
- Database CPU utilization monitoring
- Security monitoring (failed authentication attempts)
- Secret Manager access monitoring
- Email notifications to ops team and on-call staff

### Staging Monitoring:
- Less aggressive thresholds for development use
- Application error tracking
- Basic uptime monitoring
- Email notifications to development team

### Required Configuration:
```bash
# Add to your terraform.tfvars
alert_email_address = "your-team@company.com"
critical_alert_email_address = "oncall@company.com"  # Production only
```