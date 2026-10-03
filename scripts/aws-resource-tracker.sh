#!/bin/bash

########################################
# AWS Resource Tracker
# Author: Dhananjay
# Version: v4
# Purpose: AWS resource auditing,
#          reporting and support automation
########################################

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

CONFIG_FILE="$PROJECT_DIR/config/aws-resource-tracker.conf"

if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
fi

REPORT_DIR="${REPORT_DIR:-reports}"
LOG_DIR="${LOG_DIR:-logs}"

[[ "$REPORT_DIR" = /* ]] || REPORT_DIR="$PROJECT_DIR/$REPORT_DIR"
[[ "$LOG_DIR" = /* ]] || LOG_DIR="$PROJECT_DIR/$LOG_DIR"

TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
REPORT_FILE="$REPORT_DIR/aws-resource-report-$TIMESTAMP.txt"
LOG_FILE="$LOG_DIR/aws-resource-tracker.log"

SUCCESS_COUNT=0
ERROR_COUNT=0

mkdir -p "$REPORT_DIR" "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# --------------------------------------
# Dependency checks
# --------------------------------------

if ! command -v aws >/dev/null 2>&1; then
    log "ERROR: AWS CLI is not installed."
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    log "ERROR: jq is not installed."
    exit 1
fi

# --------------------------------------
# AWS authentication
# --------------------------------------

if ! aws sts get-caller-identity >/dev/null 2>&1; then
    log "ERROR: AWS authentication/configuration failed."
    exit 1
fi

log "AWS authentication check: PASSED"

ACCOUNT_ID=$(aws sts get-caller-identity \
    --query 'Account' \
    --output text)

IDENTITY_ARN=$(aws sts get-caller-identity \
    --query 'Arn' \
    --output text)

REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-}}"

if [[ -z "$REGION" ]]; then
    REGION=$(curl -sS \
        -H "X-aws-ec2-metadata-token: $(curl -sS -X PUT \
        "http://169.254.169.254/latest/api/token" \
        -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")" \
        http://169.254.169.254/latest/meta-data/placement/region 2>/dev/null || true)
fi

if [[ -z "$REGION" ]]; then
    REGION="unknown"
fi

# --------------------------------------
# Report header
# --------------------------------------

echo "========================================" | tee "$REPORT_FILE"
echo "          AWS RESOURCE TRACKER" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"
echo "Generated : $(date)" | tee -a "$REPORT_FILE"
echo "Account   : $ACCOUNT_ID" | tee -a "$REPORT_FILE"
echo "Region    : $REGION" | tee -a "$REPORT_FILE"
echo "Identity  : $IDENTITY_ARN" | tee -a "$REPORT_FILE"
echo | tee -a "$REPORT_FILE"

# --------------------------------------
# EC2
# --------------------------------------

echo "===== EC2 INSTANCES =====" | tee -a "$REPORT_FILE"

if EC2_OUTPUT=$(aws ec2 describe-instances \
    --query 'Reservations[].Instances[].InstanceId' \
    --output text 2>> "$LOG_FILE"); then

    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))

    if [[ -n "$EC2_OUTPUT" && "$EC2_OUTPUT" != "None" ]]; then
        echo "$EC2_OUTPUT" | tr '\t' '\n' | tee -a "$REPORT_FILE"
        EC2_COUNT=$(echo "$EC2_OUTPUT" | tr '\t' '\n' | grep -c . || true)
    else
        echo "No EC2 instances found." | tee -a "$REPORT_FILE"
        EC2_COUNT=0
    fi

else
    ERROR_COUNT=$((ERROR_COUNT + 1))
    log "ERROR: Failed to retrieve EC2 instances."
    EC2_COUNT=0
fi

echo "EC2 Count: $EC2_COUNT" | tee -a "$REPORT_FILE"
echo | tee -a "$REPORT_FILE"

# --------------------------------------
# S3
# --------------------------------------

echo "===== S3 BUCKETS =====" | tee -a "$REPORT_FILE"

if S3_OUTPUT=$(aws s3 ls 2>> "$LOG_FILE"); then

    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))

    if [[ -n "$S3_OUTPUT" ]]; then
        echo "$S3_OUTPUT" | tee -a "$REPORT_FILE"
        S3_COUNT=$(echo "$S3_OUTPUT" | grep -c . || true)
    else
        echo "No S3 buckets found." | tee -a "$REPORT_FILE"
        S3_COUNT=0
    fi

else
    ERROR_COUNT=$((ERROR_COUNT + 1))
    log "ERROR: Failed to retrieve S3 buckets."
    S3_COUNT=0
fi

echo "S3 Bucket Count: $S3_COUNT" | tee -a "$REPORT_FILE"
echo | tee -a "$REPORT_FILE"

# --------------------------------------
# Lambda
# --------------------------------------

echo "===== LAMBDA FUNCTIONS =====" | tee -a "$REPORT_FILE"

if LAMBDA_OUTPUT=$(aws lambda list-functions \
    --query 'Functions[].FunctionName' \
    --output text 2>> "$LOG_FILE"); then

    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))

    if [[ -n "$LAMBDA_OUTPUT" && "$LAMBDA_OUTPUT" != "None" ]]; then
        echo "$LAMBDA_OUTPUT" | tr '\t' '\n' | tee -a "$REPORT_FILE"
        LAMBDA_COUNT=$(echo "$LAMBDA_OUTPUT" | tr '\t' '\n' | grep -c . || true)
    else
        echo "No Lambda functions found." | tee -a "$REPORT_FILE"
        LAMBDA_COUNT=0
    fi

else
    ERROR_COUNT=$((ERROR_COUNT + 1))
    log "ERROR: Failed to retrieve Lambda functions."
    LAMBDA_COUNT=0
fi

echo "Lambda Function Count: $LAMBDA_COUNT" | tee -a "$REPORT_FILE"
echo | tee -a "$REPORT_FILE"

# --------------------------------------
# IAM
# --------------------------------------

echo "===== IAM USERS =====" | tee -a "$REPORT_FILE"

if IAM_OUTPUT=$(aws iam list-users \
    --query 'Users[].UserName' \
    --output text 2>> "$LOG_FILE"); then

    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))

    if [[ -n "$IAM_OUTPUT" && "$IAM_OUTPUT" != "None" ]]; then
        echo "$IAM_OUTPUT" | tr '\t' '\n' | tee -a "$REPORT_FILE"
        IAM_COUNT=$(echo "$IAM_OUTPUT" | tr '\t' '\n' | grep -c . || true)
    else
        echo "No IAM users found." | tee -a "$REPORT_FILE"
        IAM_COUNT=0
    fi

else
    ERROR_COUNT=$((ERROR_COUNT + 1))
    log "ERROR: Failed to retrieve IAM users."
    IAM_COUNT=0
fi

echo "IAM User Count: $IAM_COUNT" | tee -a "$REPORT_FILE"
echo | tee -a "$REPORT_FILE"

# --------------------------------------
# Final summary
# --------------------------------------

echo "========================================" | tee -a "$REPORT_FILE"
echo "           TRACKING SUMMARY" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"
echo "Successful checks : $SUCCESS_COUNT" | tee -a "$REPORT_FILE"
echo "Failed checks     : $ERROR_COUNT" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"

if [[ "$ERROR_COUNT" -eq 0 ]]; then
    log "AWS resource tracking completed successfully."
else
    log "AWS resource tracking completed with $ERROR_COUNT error(s)."
    exit 1
fi
