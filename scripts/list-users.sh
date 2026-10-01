#!/bin/bash

########################################
# GitHub Repository Access Tracker
# Author: Dhananjay
# Version: v2
########################################

set -euo pipefail

API_URL="https://api.github.com"

# Credentials must be provided through environment variables
USERNAME="${GITHUB_USERNAME:-}"
TOKEN="${GITHUB_TOKEN:-}"

REPO_OWNER="${1:-}"
REPO_NAME="${2:-}"

# Validate required configuration
if [[ -z "$USERNAME" || -z "$TOKEN" ]]; then
    echo "ERROR: GitHub credentials are not configured."
    echo "Set GITHUB_USERNAME and GITHUB_TOKEN environment variables."
    exit 1
fi

if [[ -z "$REPO_OWNER" || -z "$REPO_NAME" ]]; then
    echo "Usage: $0 <repo_owner> <repo_name>"
    exit 1
fi

# GitHub API GET request
github_api_get() {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"

    curl -sS \
        -u "${USERNAME}:${TOKEN}" \
        -H "Accept: application/vnd.github+json" \
        "$url"
}

# List collaborators with read permission
list_users_with_read_access() {

    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"

    local response

    response="$(github_api_get "$endpoint")"

    # Check GitHub API response
    if echo "$response" | jq -e 'type == "object" and has("message")' >/dev/null 2>&1; then
        echo "ERROR: GitHub API returned an error:"
        echo "$response" | jq -r '.message'
        exit 1
    fi

    collaborators="$(
        echo "$response" |
        jq -r '.[] | select(.permissions.pull == true) | .login'
    )"

    if [[ -z "$collaborators" ]]; then
        echo "No users with read access found for ${REPO_OWNER}/${REPO_NAME}."
    else
        echo "Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
        echo "$collaborators"
    fi
}

echo "========================================"
echo "       GITHUB ACCESS TRACKER"
echo "========================================"
echo "Repository: ${REPO_OWNER}/${REPO_NAME}"
echo

list_users_with_read_access
