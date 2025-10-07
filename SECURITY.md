# Security Best Practices and Implementation Guide

## Overview
This document outlines the security improvements implemented in this GCP Terraform configuration to follow least privilege principles and security best practices.

## Security Improvements Implemented

### 1. IAM Permission Reduction (Least Privilege)

#### Before (Overly Permissive):
- Cloud Run Job service account had `roles/editor` (full project access)
- Service accounts had `roles/storage.admin` (all storage buckets)
- Unnecessary IAM roles like `roles/iam.serviceAccountTokenCreator`

#### After (Least Privilege):
- **Cloud Run Service Account**: Limited to specific required permissions:
  - `roles/cloudsql.client` - Database access only
  - `roles/secretmanager.secretAccessor` - Secret access only
  - `roles/documentai.editor` - Document AI access (reduced from admin)
  - `roles/errorreporting.writer` - Error reporting (reduced from admin)
  - `roles/logging.logWriter` - Log writing only
  - Bucket-specific `roles/storage.objectAdmin` instead of project-wide storage admin

- **Cloud Build Service Account**: Minimal permissions:
  - `roles/run.developer` - Cloud Run deployment only
  - `roles/iam.serviceAccountUser` - Service account usage
  - `roles/artifactregistry.writer` - Artifact registry access
  - Bucket-specific `roles/storage.objectAdmin` for build artifacts

- **Cloud Run Job Service Account**: Restricted permissions:
  - `roles/secretmanager.secretAccessor` - Secret access only
  - `roles/logging.logWriter` - Logging capability
  - `roles/cloudsql.client` - Database access

### 2. Public Access Removal

#### Security Issue Fixed:
- Removed `member = "allUsers"` from Cloud Run services in both production and staging
- Services are no longer publicly accessible without authentication

#### Recommendation:
For production use, implement one of the following authentication methods:
- **Cloud Identity-Aware Proxy (IAP)** for Google authentication
- **Custom authentication** in your application
- **VPC-native networking** with private endpoints
- **API Gateway** with authentication

### 3. Production Security Hardening

#### Debug Mode Disabled:
- Changed `APP_DEBUG = "false"` in production environment
- Prevents sensitive debugging information from being exposed

#### Monitoring APIs Added:
- `monitoring.googleapis.com` - For alerting and monitoring
- `logging.googleapis.com` - For log analysis and security monitoring

### 4. Comprehensive Monitoring and Alerting

#### Production Monitoring Features:
- **Uptime Monitoring**: Checks service availability every 60 seconds
- **Error Rate Alerts**: Triggers when error rate exceeds 10 requests/5 minutes
- **Database CPU Monitoring**: Alerts when CPU usage exceeds 80%
- **Failed Authentication Alerts**: Detects potential brute force attacks (>20 failed attempts/5 minutes)
- **Secret Manager Access Monitoring**: Unusual secret access patterns (>100 requests/5 minutes)
- **Application Error Tracking**: Log-based metrics for application errors

#### Staging Monitoring Features:
- **Reduced Alert Frequency**: Less aggressive thresholds for development environment
- **Uptime Monitoring**: Checks every 5 minutes
- **Higher Error Thresholds**: More tolerant of testing-related errors

#### Email Notifications:
- **Production**: Separate channels for general alerts and critical alerts
- **Staging**: Single email channel for development team notifications

## Required Configuration

### Environment Variables to Set:
```bash
# Production
alert_email_address = "ops-team@yourcompany.com"
critical_alert_email_address = "oncall@yourcompany.com"

# Staging  
alert_email_address = "dev-team@yourcompany.com"
```

### APIs That Will Be Enabled:
- `monitoring.googleapis.com` - Google Cloud Monitoring
- `logging.googleapis.com` - Google Cloud Logging

## Security Monitoring Features

### 1. Failed Authentication Detection
- Monitors application logs for authentication failures
- Configurable thresholds to detect brute force attacks
- Immediate email notifications for security team

### 2. Unusual Access Patterns
- Tracks Secret Manager access frequency
- Alerts on abnormal secret access patterns
- Helps detect potential credential theft or misuse

### 3. Service Availability Monitoring
- Continuous uptime checks for critical services
- Immediate alerts when services become unavailable
- Different SLAs for production vs staging environments

### 4. Application Error Tracking
- Log-based metrics for application errors
- Trend analysis for error rates
- Early warning system for application issues

## Implementation Notes

### Storage Security:
- Replaced project-wide `roles/storage.admin` with bucket-specific `roles/storage.objectAdmin`
- Each service account only has access to its designated bucket
- Prevents cross-bucket access and data leakage

### Database Security:
- Maintained `roles/cloudsql.client` for database connectivity
- Removed unnecessary elevated permissions
- Database access is limited to specific instances

### Secret Management:
- Maintained `roles/secretmanager.secretAccessor` for application secrets
- Added monitoring for unusual access patterns
- No changes to secret rotation policies (implement separately)

## Recommendations for Further Security Improvements

### 1. Network Security:
- Implement VPC-native networking
- Use Private Google Access for internal communications
- Configure Cloud NAT for outbound internet access

### 2. Authentication:
- Implement Cloud Identity-Aware Proxy for user authentication
- Use service-to-service authentication for internal APIs
- Implement OAuth 2.0 or OpenID Connect for external integrations

### 3. Data Protection:
- Enable Cloud SQL encryption at rest
- Use Cloud KMS for application-level encryption
- Implement data classification and DLP policies

### 4. Compliance:
- Enable Cloud Audit Logs for all services
- Implement data retention policies
- Set up compliance monitoring and reporting

### 5. Incident Response:
- Create runbooks for common security incidents
- Implement automated response for critical alerts
- Regular security drills and testing

## Testing the Configuration

### Before Deployment:
1. Update `terraform.tfvars` with your email addresses
2. Run `terraform plan` to review changes
3. Verify no unexpected resource deletions
4. Test monitoring configuration in staging first

### After Deployment:
1. Verify email notifications are working
2. Test alert thresholds by triggering test conditions
3. Validate that services are no longer publicly accessible
4. Check that bucket permissions are correctly scoped
5. Monitor logs for any permission-related errors

## Emergency Procedures

### If Services Become Inaccessible:
1. Check Cloud Run IAM permissions
2. Verify service account configurations
3. Review recent Terraform changes
4. Use Google Cloud Console for emergency access restoration

### If Alerts Are Too Noisy:
1. Adjust thresholds in monitoring.tf
2. Modify alert durations
3. Update notification channels
4. Consider staging vs production alert differences

This security implementation significantly improves the security posture while maintaining operational functionality. Regular review and updates of these security measures are recommended.