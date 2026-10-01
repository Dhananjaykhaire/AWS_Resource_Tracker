#!/bin/bash

########################################
# AWS Resource Tracker
# Author: Dhananjay
# Version: v3
# Purpose: AWS resource auditing and
#          scheduled support automation
########################################

set -euo pipefail

# Use $HOME so it works for any user
REPORT_DIR="$HOME/aws-resource-tracker/reports"
LOG_DIR="$HOME/aws-resource-tracker/logs"

TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
REPORT_FILE="$REPORT_DIR/aws-resource-report-$TIMESTAMP.txt"
LOG_FILE="$LOG_DIR/aws-resource-tracker.log"

mkdir -p "$REPORT_DIR" "$LOG_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

echo "========================================" | tee "$REPORT_FILE"
echo "       AWS RESOURCE TRACKER" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"
echo "Date: $(date)" | tee -a "$REPORT_FILE"
echo | tee -a "$REPORT_FILE"

# Check AWS CLI
if ! command -v aws >/dev/null 2>&1; then
    log "ERROR: AWS CLI is not installed."
    exit 1
fi

# Check jq
if ! command -v jq >/dev/null 2>&1; then
    log "ERROR: jq is not installed."
    exit 1
fi

# Check AWS authentication
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    log "ERROR: AWS authentication/configuration failed."
    log "Check your AWS CLI credentials/configuration."
    exit 1
fi

log "AWS authentication check: PASSED"

echo | tee -a "$REPORT_FILE"
echo "===== EC2 INSTANCES =====" | tee -a "$REPORT_FILE"

if ! aws ec2 describe-instances \
    --query 'Reservations[].Instances[].InstanceId' \
    --output text >> "$REPORT_FILE" 2>> "$LOG_FILE"; then
    log "ERROR: Failed to retrieve EC2 instances."
fi

echo | tee -a "$REPORT_FILE"
echo "===== S3 BUCKETS =====" | tee -a "$REPORT_FILE"

if ! aws s3 ls >> "$REPORT_FILE" 2>> "$LOG_FILE"; then
    log "ERROR: Failed to retrieve S3 buckets."
fi

echo | tee -a "$REPORT_FILE"
echo "===== LAMBDA FUNCTIONS =====" | tee -a "$REPORT_FILE"

if ! aws lambda list-functions \
    --query 'Functions[].FunctionName' \
    --output text >> "$REPORT_FILE" 2>> "$LOG_FILE"; then
    log "ERROR: Failed to retrieve Lambda functions."
fi

echo | tee -a "$REPORT_FILE"
echo "===== IAM USERS =====" | tee -a "$REPORT_FILE"

if ! aws iam list-users \
    --query 'Users[].UserName' \
    --output text >> "$REPORT_FILE" 2>> "$LOG_FILE"; then
    log "ERROR: Failed to retrieve IAM users."
fi

echo | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"
echo "Report generated: $REPORT_FILE" | tee -a "$REPORT_FILE"
echo "========================================" | tee -a "$REPORT_FILE"

log "AWS resource tracking completed successfully."

