# AWS Resource Tracker Documentation 📘

## 📌 Overview
This script helps DevOps engineers monitor AWS resource usage efficiently by utilizing **AWS CLI** commands.

## 🛠️ AWS CLI Commands Used
- `aws ec2 describe-instances` → List EC2 instances
- `aws s3 ls` → List S3 buckets
- `aws iam list-users` → List IAM users
- `aws rds describe-db-instances` → List RDS instances

## 🔧 Setup Instructions
1. Ensure AWS CLI is installed:  
   ```bash
   aws --version

Configure AWS credentials
aws configure

Assign necessary IAM policies.
Fetching AWS resource usage...
EC2 Instances:
- Instance ID: i-xxxxxxxxxx
- State: running
S3 Buckets:
- my-first-bucket
- my-second-bucket

