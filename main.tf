provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "sports_data_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "sports_data_versioning" {
  bucket = aws_s3_bucket.sports_data_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# IAM role for CodeBuild
resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-sports-data-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Custom inline policy for the IAM role
resource "aws_iam_role_policy" "codebuild_custom_policy" {
  name = "codebuild-sports-data-policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:CreateBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::sports-bucket",
          "arn:aws:s3:::sports-bucket/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "glue:CreateDatabase",
          "glue:DeleteDatabase",
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:CreateTable",
          "glue:DeleteTable",
          "glue:GetTable",
          "glue:GetTables",
          "glue:UpdateTable"
        ],
        Resource = [
          "arn:aws:glue:*:*:catalog",
          "arn:aws:glue:*:*:database/glue_sports_data_lake",
          "arn:aws:glue:*:*:table/glue_sports_data_lake/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "athena:StartQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject"
        ],
        Resource = [
          "arn:aws:s3:::sports-bucket/athena-results/*"
        ]
      }
    ]
  })
}

# CodeBuild project
resource "aws_codebuild_project" "sports_data_build" {
  name         = "sports-data-build"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  source {
    type      = "GITHUB"
    location  = "https://github.com/ctpitt/sports-data-lake.git"
    buildspec = "buildspec.yml"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:6.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "S3_BUCKET_NAME"
      value = var.bucket_name
    }

    environment_variable {
      name  = "GLUE_DB_NAME"
      value = var.glue_db_name
    }

    environment_variable {
      name  = "SPORTS_DATA_API_KEY"
      value = var.sports_api_key
    }

    environment_variable {
      name  = "NBA_ENDPOINT"
      value = var.nba_endpoint
    }
  }

  source_version = "main"
}
