#------------Region-------------------
variable "aws_region" {
  description = "The AWS region to deploy resources into"
  type        = string
  default     = "ap-southeast-1" # Defaults to Singapore; change as needed
}

#------------Bucket-------------------
variable "bucket_name" {
  description = "The globally unique name for the S3 bucket hosting the website"
  type        = string
}

#------------Tags-------------------
variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default = {
    Environment = "Dev"
    Project     = "Static-Website"
    ManagedBy   = "Terraform"
  }
}