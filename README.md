
# SportsDataLake

This repository contains the `setup_sports_data_lake.py` script and Terraform files that automate the creation of a sports analytics data lake using AWS services. It integrates with the SportsDataIO API and provisions infrastructure via Terraform, storing data in Amazon S3, cataloging it with AWS Glue, and querying it using Amazon Athena.

# Overview

This solution uses Terraform to automate the deployment of a CI/CD pipeline that performs the following:

- Provisions AWS infrastructure including S3, Glue, Athena, IAM, and CodeBuild
- Retrieves NBA player data from SportsDataIO API
- Uploads that data to an `nba/raw-data/` folder in Amazon S3
- Creates an AWS Glue catalog table for the data
- Configures Amazon Athena for SQL queries on the data
- All triggered automatically when new code is pushed to GitHub via AWS CodePipeline

# Prerequisites

Before deploying the project:

1. Go to [SportsDataIO](https://sportsdata.io) and sign up for a free account.
2. Navigate to **Developers > API Resources** > NBA.
3. Copy your API key from the **"Query String Parameters"** section.
4. Make sure your AWS account has permissions to create the following services:

   - S3: `s3:CreateBucket`, `s3:PutObject`, `s3:ListBucket`
   - Glue: `glue:CreateDatabase`, `glue:CreateTable`
   - Athena: `athena:StartQueryExecution`, `athena:GetQueryResults`
   - IAM: `iam:CreateRole`, `iam:AttachRolePolicy`
   - CodeBuild, CodePipeline

# Project Structure

```text
.
├── buildspec.yml               # Instructions for CodeBuild
├── main.tf                     # Terraform: infrastructure definition
├── outputs.tf                  # Terraform: output values
├── setup_sports_data_lake.py  # Python script: data ingestion
├── variables.tf                # Terraform: input variables
├── .gitignore                  # Prevents committing sensitive files
```

# Deployment Steps

## Step 1: Add your API credentials (securely)

Create a `terraform.tfvars` file (not committed to GitHub) and add:

```hcl
sports_api_key = "your_sportsdataio_api_key"
nba_endpoint   = "https://api.sportsdata.io/v3/nba/scores/json/Players"
```

## Step 2: Initialize and apply Terraform

In your terminal:

```bash
terraform init
terraform apply
```

Terraform will:

- Create the S3 bucket, Glue DB, IAM roles, and CodeBuild project
- Configure CodePipeline to listen for GitHub changes
- Inject environment variables into CodeBuild from your `tfvars`

## Step 3: Push to GitHub

```bash
git add .
git commit -m "Initial setup for sports data lake"
git push origin main
```

CodePipeline will trigger automatically, and CodeBuild will:

- Fetch NBA data from the SportsDataIO API
- Upload it to `s3://sports-bucket/nba/raw-data/`
- Create a Glue table
- Configure Athena

# Query the Data in Athena

1. Go to the **Amazon Athena** console.
2. Set your query result location to `s3://sports-bucket/athena-results/`.
3. Run this sample query:

```sql
SELECT FirstName, LastName, Position, Team
FROM nba_players
WHERE Position = 'PG';
```

# What We Learned

1. How to automate AWS resource creation using Terraform
2. How to integrate external APIs with AWS CodeBuild
3. How to build a reusable, secure, serverless data pipeline
4. How to make your infrastructure deployment repeatable and cloud-native

# Future Enhancements

1. Extend support for other sports like NFL and MLB
2. Add a transformation layer with AWS Glue ETL
3. Schedule recurring data updates with EventBridge or Step Functions
4. Visualize insights using Amazon QuickSight or Power BI
