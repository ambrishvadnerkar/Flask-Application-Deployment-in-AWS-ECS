# Flask Application CI/CD with GitHub Actions

This repository contains a Flask application with a CI/CD pipeline implemented using GitHub Actions. The pipeline builds, tests, and deploys the application to AWS ECS using Terraform and Amazon Elastic Container Registry (ECR).

## CI/CD Workflow Overview

The GitHub workflow automates the following tasks:

1. **Code Quality & Security Scan**: Lints the code using `flake8` and performs dependency security checks with `safety`.
2. **Docker Build & Push**: Builds a Docker image and pushes it to AWS ECR.
3. **Deployment**: Deploys the application to AWS ECS Fargate using Terraform-generated infrastructure details.
4. **Integration Testing**: Performs basic health checks using `curl`.

## GitHub Workflow Files

- **[`cicd.yml`](.github/workflows/cicd.yml)**: Main CI/CD pipeline file that defines the build, security scan, and deployment steps.
- **[`reusable-deployment.yml`](.github/workflows/reusable-deployment.yml)**: A reusable workflow for deploying the application to AWS ECS.

## Required Repository Secrets

To configure the pipeline, set the following GitHub repository secrets:

| Secret Name             | Description                    |
| ----------------------- | ------------------------------ |
| `AWS_ACCOUNT_ID`        | AWS account ID                 |
| `AWS_ACCESS_KEY_ID`     | AWS IAM user access key ID     |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM user secret access key |

## Required Repository Variables

The following repository-level variables need to be set:

| Variable Name        | Description                                               |
| -------------------- | --------------------------------------------------------- |
| `APP_CONTAINER_NAME` | Name of the container running the Flask app               |
| `APP_URL`            | Application's URL                                         |
| `AWS_REGION`         | AWS region where resources are deployed                   |
| `ECR_REPOSITORY`     | Name of the AWS ECR repository (must be created manually) |
| `ECS_CLUSTER`        | Name of the ECS cluster                                   |
| `ECS_SERVICE`        | Name of the ECS service                                   |
| `TASK_DEF_ARN`       | Amazon Resource Name (ARN) of the ECS task definition     |

> **Note**: Except for `ECR_REPOSITORY`, all values for these variables are generated during the Terraform infrastructure setup and will be displayed in the output.

## Setting Up the Pipeline

### Step 1: Create an AWS ECR Repository

Before running the pipeline, manually create an AWS ECR repository and set its name in the repository variables under `ECR_REPOSITORY`.

### Step 2: Configure GitHub Secrets and Variables

- Navigate to **Repository Settings → Secrets and Variables → Actions**.
- Add the required secrets under **Secrets**.
- Add the required variables under **Variables**.

### Step 3: Push Code to `main` Branch

The pipeline is triggered automatically on every push to the `main` branch.

## Deployment Process

1. **Code Scan**: Ensures code quality and security before proceeding with the build.
2. **Docker Build & Push**: Builds the Docker image and pushes it to ECR.
3. **ECS Deployment**:
   - Renders the ECS task definition with the new image.
   - Checks if the ECS service exists.
   - If the service exists, it deploys the new task definition.
4. **Integration Testing**: Runs health checks against the deployed application.

## Troubleshooting

- **Deployment Failure**:

  - Verify the AWS credentials and repository variables are correctly set.
  - Check GitHub Actions logs for detailed error messages.
  - Ensure the ECS cluster and service exist in AWS.

- **ECR Login Issues**:

  - Run `aws ecr get-login-password --region <AWS_REGION> | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com` manually to validate authentication.

