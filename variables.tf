variable "sports_api_key" {
  description = "SportsDataIO API Key"
  type        = string
  sensitive   = true
}

variable "nba_endpoint" {
  description = "NBA API Endpoint"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "glue_db_name" {
  description = "Name of the Glue database"
  type        = string
}
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
variable "github_oauth_token" {
  description = "GitHub OAuth token for CodePipeline"
  type        = string
}
