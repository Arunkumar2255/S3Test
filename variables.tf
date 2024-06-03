variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "log_bucket_name" {
  description = "The name of the S3 bucket for access logs"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allows the bucket to be deleted even if it contains objects"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to resources"
  type        = map(string)
  default     = {
    Environment = "production"
    Project     = "example-project"
  }
}


