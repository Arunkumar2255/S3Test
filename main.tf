Enable Versioning, Use Server-Side Encryption,Enable Access Logging,Set Up Bucket Policies and IAM Policies,Enable Multi-Factor Authentication (MFA) Delete,Use Lifecycle Policies, Implement Cross-Region Replication, Enable Object Lock,Use S3 Storage Class Analysis,Implement Data Transfer Acceleration

Enable IAM Role for Service Accounts (IRSA),Use Managed Node Groups,Enable Cluster Logging,Use Network Policies,Enable Secrets Encryption,Configure Auto Scaling,Implement Pod Security Standards,Regularly Update Kubernetes Version,Use VPC CNI Plugin,Set Resource Requests and Limits

Ensure that the CoreDNS add-on version matches the EKS cluster's Kubernetes version.,Ensure that remote access to EKS cluster node groups is disabled,Ensure that AWS EKS cluster endpoint access isn't public and prone to security risks.,Ensure that EKS Cluster node groups are using appropriate permissions.,Ensure that AWS EKS security groups are configured to allow incoming traffic only on TCP port 443.,Ensure that all Kubernetes API calls are logged using Amazon CloudTrail.,Ensure that envelope encryption of Kubernetes secrets using Amazon KMS is enabled.,Ensure that EKS control plane logging is enabled for your Amazon EKS clusters.,Ensure that the latest version of Kubernetes is installed on your Amazon EKS clusters.,Amazon EKS configuration changes have been detected within your Amazon Web Services account.,Ensure that EKS cluster node groups implement the "AmazonEKS_CNI_Policy" managed policy.,Ensure that EKS cluster node groups implement the "AmazonEC2ContainerRegistryReadOnly" managed policy.,Ensure that Amazon EKS clusters implement the "AmazonEKSClusterPolicy" managed policy.,Ensure that Amazon EKS clusters are using an OpenID Connect (OIDC) provider.

Ensure EFS file systems are encrypted with KMS Customer Master Keys (CMKs) in order to have full control over data encryption and decryption., Ensure encryption is enabled for AWS EFS file systems to protect your data at rest.
------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "main" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy
  tags          = merge({
    Name = var.bucket_name
  }, var.tags)

  versioning {
    enabled = var.versioning_enabled
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  logging {
    target_bucket = var.log_bucket_name
    target_prefix = "log/"
  }

  lifecycle_rule {
    id      = "log"
    enabled = true

    filter {
      prefix = "log/"
    }

    expiration {
      days = 90
    }
  }
}

resource "aws_s3_bucket" "log_bucket" {
  bucket        = var.log_bucket_name
  force_destroy = true
  acl           = "log-delivery-write"
  tags          = merge({
    Name = var.log_bucket_name
  }, var.tags)

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.bucket

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::123456789012:user/some-user"]
    }
  }
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
}


