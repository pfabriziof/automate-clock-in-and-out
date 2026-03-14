# Automate Clock-In and Out

Automated clock-in and clock-out for [Talana](https://talana.com/) using AWS serverless infrastructure. EventBridge Schedulers trigger a Lambda function on a cron schedule, which authenticates against the Talana API and registers the attendance mark.

---

## Features

- Automated clock-in and clock-out via Talana's REST API
- Separate schedules for weekdays and Fridays clock-out
- Random delay on execution to simulate natural human behavior
- Credentials and config securely stored in AWS Secrets Manager
- Pydantic-validated event payload and app configuration
- Structured error handling with custom exception hierarchy
- Docker-based Lambda deployment using a multi-stage build
- Fully reproducible infrastructure as code with Terraform

---

## Architecture

> Architecture diagram coming soon.

---

## Technologies

| Layer          | Technology                          |
|----------------|-------------------------------------|
| Infrastructure | Terraform (HCL)                     |
| Runtime        | Python 3.12                         |
| Packaging      | Docker (multi-stage, ECR)           |
| Scheduling     | AWS EventBridge Scheduler           |
| Compute        | AWS Lambda (container image)        |
| Secrets        | AWS Secrets Manager                 |
| Observability  | AWS X-Ray, CloudWatch Logs          |
| Validation     | Pydantic v2                         |
| Dependencies   | Poetry                              |

---

## Project Structure

```
.
├── functions/
│   └── clockin_service/        # Lambda function source
│       ├── main.py             # Handler, API logic, models
│       ├── Dockerfile          # Multi-stage Docker build
│       └── pyproject.toml      # Poetry dependencies
└── iac/
    ├── architecture/           # Root Terraform module
    ├── modules/
    │   ├── clockin_service/    # Schedulers, IAM, Secrets Manager
    │   └── lambda_docker/      # Reusable Lambda + ECR module
    └── account-tfvars/         # Per-account variable files
```

---

## Getting Started

### Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- Docker
- Poetry

### Deploy

1. Push the Docker image to ECR:
   ```bash
   cd functions/clockin_service
   docker build -t clockin-service .
   # tag and push to your ECR repository
   ```

2. Deploy infrastructure:
   ```bash
   cd iac/architecture
   terraform init
   terraform apply -var-file="../account-tfvars/<account_id>.tfvars"
   ```

### Configuration

Secrets are stored in AWS Secrets Manager as a JSON object with the following keys:

```json
{
  "API_LOGIN_URL": "<talana_login_endpoint>",
  "API_CLOCKIN_URL": "<talana_clockin_endpoint>",
  "USERNAME": "<your_username>",
  "PASSWORD": "<your_password>",
  "SUCURSAL": "<your_branch_id>"
}
```

See `iac/account-tfvars/terraform.tfvars.example` for all available Terraform variables.
