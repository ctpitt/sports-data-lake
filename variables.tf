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
