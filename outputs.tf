output "s3_bucket_name" {
  description = "The name of the S3 bucket used for storing sports data"
  value       = aws_s3_bucket.sports_data_bucket.bucket
}

output "codebuild_project_name" {
  description = "The name of the AWS CodeBuild project"
  value       = aws_codebuild_project.sports_data_build.name
}

output "iam_role_name" {
  description = "The name of the IAM role used by CodeBuild"
  value       = aws_iam_role.codebuild_role.name
}
