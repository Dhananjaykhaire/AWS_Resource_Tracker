# AWS Resource Tracker with GitHub API Integration

<div align="center">

<img src="https://img.shields.io/badge/AWS-Resource%20Tracker-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Resource Tracker"/>
<img src="https://img.shields.io/badge/Bash-Automation-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white" alt="Bash"/>
<img src="https://img.shields.io/badge/Linux-Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white" alt="Linux"/>
<img src="https://img.shields.io/badge/GitHub-API-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub API"/>

<br/><br/>

**Cloud Support • Linux Administration • AWS Automation • REST API Integration**

</div>

---

## 📌 Project Overview

**AWS Resource Tracker with GitHub API Integration** is a Linux-based support automation project that combines two operational tasks:

1. **AWS resource auditing** using Bash, AWS CLI, and `jq`.
2. **GitHub repository access tracking** using the GitHub REST API, `curl`, `jq`, and token-based authentication.

The project demonstrates an operational workflow commonly useful in cloud and technical support environments:

> **Manual checking → Shell automation → Cloud CLI → API integration → Authentication → Validation → Error handling → Reporting → Scheduling**

The project is intentionally focused on **support and infrastructure operations**, rather than application development.

---

## 🎯 Objectives

- Automate repetitive AWS resource checks from a Linux terminal.
- Retrieve AWS resources using the AWS CLI.
- Generate timestamped audit reports.
- Maintain runtime logs for troubleshooting.
- Validate AWS CLI authentication before performing resource checks.
- Integrate a Bash script with the GitHub REST API.
- Retrieve repository collaborators with read-level access.
- Handle missing configuration and API-level errors.
- Keep credentials outside source code.
- Manage the project using Git and GitHub.

---

# 🏗️ Architecture

```text
                         AWS Resource Tracker
                                  │
                                  ▼
                        ┌───────────────────┐
                        │   Ubuntu / Linux  │
                        │   Bash Scripts    │
                        └─────────┬─────────┘
                                  │
                  ┌───────────────┴────────────────┐
                  │                                │
                  ▼                                ▼
        ┌──────────────────┐             ┌──────────────────┐
        │    AWS CLI       │             │  GitHub REST API │
        │ + jq             │             │ + curl + jq     │
        └────────┬─────────┘             └────────┬─────────┘
                 │                                │
       ┌─────────┼─────────┐                      │
       ▼         ▼         ▼                      ▼
      EC2       S3      Lambda                    GitHub
       │         │         │                 Repository
       └─────────┴─────────┘                      │
                 │                                │
                 ▼                                ▼
        AWS Audit Report                Repository Access
        + Runtime Logs                       Results
```

### Operational flow

```text
Linux Host
   │
   ├── Stage 1: aws-resource-tracker.sh
   │       │
   │       ├── Check AWS CLI
   │       ├── Check jq
   │       ├── Validate AWS identity
   │       ├── Query EC2
   │       ├── Query S3
   │       ├── Query Lambda
   │       └── Query IAM users
   │
   └── Stage 2: list-users.sh
           │
           ├── Validate GitHub credentials
           ├── Validate repository arguments
           ├── Call GitHub REST API
           ├── Validate API response
           ├── Filter read permission
           └── Display repository access
```

---

# 🧩 Technology Stack

| Category | Technology | Purpose |
|---|---|---|
| Operating System | Ubuntu Linux | Execution environment |
| Shell | Bash | Automation and control flow |
| Cloud | AWS | Cloud resource environment |
| AWS Interface | AWS CLI | Query AWS resources |
| JSON Processing | jq | Parse/filter JSON |
| API Client | curl | HTTP/API requests |
| API | GitHub REST API | Repository access information |
| Authentication | AWS CLI credentials / GitHub token | Secure API authentication |
| Version Control | Git | Source control |
| Repository | GitHub | Remote source repository |
| Scheduling | cron | Periodic AWS audit execution |
| Networking | HTTPS / SSH | API access and Git transport |

---

# 🔧 Prerequisites

## 1. Linux / Ubuntu

A Linux environment is required.

Recommended:

- Ubuntu 22.04+ / compatible Ubuntu environment
- SSH terminal access
- Bash shell

Verify:

```bash
uname -a
bash --version
```

## 2. AWS CLI

Install and configure AWS CLI.

Verify:

```bash
aws --version
```

Test authentication:

```bash
aws sts get-caller-identity
```

The AWS identity must have permission to read the resources queried by the tracker.

## 3. jq

Used for JSON parsing and filtering.

Verify:

```bash
jq --version
```

## 4. curl

Used by Stage 2 for GitHub API requests.

Verify:

```bash
curl --version
```

## 5. Git

Required for source control.

Verify:

```bash
git --version
```

## 6. GitHub account and repository

A GitHub repository is required for Stage 2 testing and project source control.

## 7. GitHub token

Stage 2 requires a GitHub token supplied through an environment variable.

Example:

```bash
export GITHUB_USERNAME="your-github-username"
export GITHUB_TOKEN="your-token"
```

**Never hard-code the token in the script, README, screenshots, Git history, or GitHub repository.**

---

# 📁 Project Structure

```text
aws-resource-tracker/
├── scripts/
│   ├── aws-resource-tracker.sh
│   └── list-users.sh
├── reports/
│   └── .gitkeep
├── logs/
│   └── .gitkeep
├── docs/
│   ├── STAGE-1.md
│   └── STAGE-2.md
├── README.md
└── .gitignore
```

### Runtime directories

`reports/` stores generated AWS audit reports.

`logs/` stores runtime/error logs.

Generated runtime files are intentionally ignored by Git.

---

# 🚀 Stage 1 — AWS Resource Automation

## Purpose

Stage 1 automates AWS resource auditing from a Linux host.

The script:

- validates required commands
- validates AWS authentication
- queries AWS resources
- creates a timestamped report
- records operational messages/errors in a log

### Script

```text
scripts/aws-resource-tracker.sh
```

### AWS resources covered

- EC2 instances
- S3 buckets
- Lambda functions
- IAM users

---

## Stage 1 Workflow

```text
Start
  │
  ▼
Check AWS CLI
  │
  ▼
Check jq
  │
  ▼
Validate AWS authentication
  │
  ├── Failed ──► Log error ──► Exit
  │
  ▼
Create reports/ and logs/
  │
  ▼
Query EC2
  │
  ▼
Query S3
  │
  ▼
Query Lambda
  │
  ▼
Query IAM users
  │
  ▼
Write timestamped report
  │
  ▼
Write completion log
  │
  ▼
End
```

## Run Stage 1

From the project directory:

```bash
./scripts/aws-resource-tracker.sh
```

A report is generated under:

```text
reports/aws-resource-report-YYYY-MM-DD_HH-MM-SS.txt
```

Runtime logs are written to:

```text
logs/aws-resource-tracker.log
```

## Stage 1 validation

Useful commands:

```bash
aws sts get-caller-identity
aws ec2 describe-instances
aws s3 ls
aws lambda list-functions
aws iam list-users
```

Then execute:

```bash
./scripts/aws-resource-tracker.sh
```

Check generated files:

```bash
ls -lh reports/
tail -n 20 logs/aws-resource-tracker.log
```

---

# ⏰ Stage 1 Scheduling with cron

The tracker can be scheduled with cron.

Example:

```cron
0 9 * * * /home/ubuntu/aws-resource-tracker/scripts/aws-resource-tracker.sh
```

This schedules the current project script for 09:00 according to the system's configured timezone.

Check the server timezone:

```bash
timedatectl
```

Edit cron:

```bash
crontab -e
```

Verify:

```bash
crontab -l
```

For testing, a temporary schedule such as the following can be used:

```cron
*/5 * * * * /home/ubuntu/aws-resource-tracker/scripts/aws-resource-tracker.sh
```

After confirming it works, replace the test schedule with the intended schedule.

---

# 🔐 Stage 1 Authentication and Security

The script does not contain AWS access keys.

AWS authentication is delegated to the AWS CLI configuration/environment.

Validate authentication with:

```bash
aws sts get-caller-identity
```

Security principles demonstrated:

- no credentials in source code
- no credentials in Git
- least-required permissions for resource reads
- authentication validation before resource operations
- runtime data separated from source code

---

# 🌐 Stage 2 — GitHub API Integration

## Purpose

Stage 2 extends the project from cloud-resource auditing into API-based support automation.

The script uses:

```text
Bash + curl + GitHub REST API + jq
```

Script:

```text
scripts/list-users.sh
```

It accepts a repository owner and repository name:

```bash
./scripts/list-users.sh <repo_owner> <repo_name>
```

Example:

```bash
./scripts/list-users.sh Dhananjaykhaire AWS_Resource_Tracker
```

---

# Stage 2 Architecture

```text
             Ubuntu Linux
                  │
                  ▼
          list-users.sh
                  │
        ┌─────────┴─────────┐
        │                   │
        ▼                   ▼
 Environment            Repository
 Variables              Arguments
 GITHUB_USERNAME        owner/name
 GITHUB_TOKEN
        │                   │
        └─────────┬─────────┘
                  ▼
                curl
                  │
                  ▼
        GitHub REST API
                  │
                  ▼
        Collaborators API
                  │
                  ▼
                 jq
                  │
                  ▼
     Filter: permissions.pull
                  │
                  ▼
       Users with read access
```

---

# Stage 2 Workflow

```text
Start
  │
  ▼
Read GitHub username/token
  │
  ├── Missing ──► Error ──► Exit
  │
  ▼
Read repository owner/name
  │
  ├── Missing ──► Usage message ──► Exit
  │
  ▼
Build GitHub API endpoint
  │
  ▼
curl authenticated request
  │
  ▼
Validate API response
  │
  ├── API error ──► Display message ──► Exit
  │
  ▼
jq filters collaborator permissions
  │
  ▼
Display users with read access
  │
  ▼
End
```

---

# 🔑 Stage 2 Authentication

Set credentials in the shell environment:

```bash
export GITHUB_USERNAME="your-github-username"
export GITHUB_TOKEN="your-token"
```

Verify only that the variables are present:

```bash
echo "$GITHUB_USERNAME"
echo "${GITHUB_TOKEN:+TOKEN_IS_SET}"
```

Do **not** run:

```bash
echo "$GITHUB_TOKEN"
```

and do not place the token inside:

- `.sh` files
- README files
- screenshots
- Git commits
- `.git` history
- GitHub repository files

---

# ▶️ Run Stage 2

```bash
./scripts/list-users.sh Dhananjaykhaire AWS_Resource_Tracker
```

The script queries the repository collaborators endpoint and filters users whose GitHub permissions indicate read access.

---

# 🧪 Stage 2 Validation and Error Handling

The script validates:

### Missing credentials

```text
ERROR: GitHub credentials are not configured.
```

### Missing repository arguments

```text
Usage: ./scripts/list-users.sh <repo_owner> <repo_name>
```

### GitHub API error

The response is inspected with `jq`.

If GitHub returns an error object containing a `message`, the script reports the API message rather than treating the response as a normal collaborator list.

This provides basic API troubleshooting behavior.

---

# 🛠️ Troubleshooting

## AWS authentication failure

```bash
aws sts get-caller-identity
```

If this fails:

- check AWS CLI configuration
- check credentials/environment
- check IAM permissions
- confirm the intended AWS account

## AWS command permission error

Test the individual service:

```bash
aws ec2 describe-instances
aws s3 ls
aws lambda list-functions
aws iam list-users
```

## GitHub authentication failure

Check that the environment variables exist:

```bash
echo "$GITHUB_USERNAME"
echo "${GITHUB_TOKEN:+TOKEN_IS_SET}"
```

Do not print the token itself.

## GitHub API authorization/error response

Run the script with the intended repository:

```bash
./scripts/list-users.sh OWNER REPOSITORY
```

Confirm:

- repository owner is correct
- repository name is correct
- token is valid
- token has appropriate access
- repository permissions are appropriate

---

# 🔄 Git and GitHub Workflow

The project uses Git for version control.

Typical workflow:

```bash
git status
git add .
git commit -m "Describe the change"
git push origin main
```

Repository transport is configured with SSH:

```text
git@github.com:Dhananjaykhaire/AWS_Resource_Tracker.git
```

SSH authentication was configured using:

```text
~/.ssh/id_ed25519_github
```

The private key must remain on the machine and must never be committed.

---

# 🧹 .gitignore and Runtime Data

The repository ignores:

```text
.env
.env.*
.aws/
*.pem
logs/*
reports/*
```

while retaining:

```text
logs/.gitkeep
reports/.gitkeep
```

This keeps generated operational data out of the source repository while preserving the intended directory structure.

---

# 📊 Project Stages

| Stage | Focus | Status |
|---|---|---|
| Stage 1 | Bash + AWS CLI automation | ✅ Completed |
| Stage 2 | GitHub REST API integration | ✅ Completed |
| Stage 3 | Reliability and deeper error handling | Planned |
| Stage 4 | Reporting improvements | Planned |
| Stage 5 | Configuration management | Planned |
| Stage 6 | Git/GitHub workflow improvements | Planned |

Only completed functionality should be represented as completed in the resume or project description.

---

# 🎓 Learning Outcomes

By completing Stages 1 and 2, the project demonstrates practical experience with:

- Linux command-line operations
- Bash scripting
- shell variables and functions
- conditionals and validation
- exit codes
- `set -euo pipefail`
- AWS CLI
- EC2, S3, Lambda and IAM resource queries
- JSON processing with `jq`
- REST API concepts
- HTTP requests with `curl`
- GitHub API integration
- token-based authentication
- API response validation
- basic permission/error troubleshooting
- cron scheduling
- Git/GitHub
- SSH-based Git authentication
- `.gitignore` and repository hygiene

---

# 💼 Support / Cloud Operations Relevance

This project is designed around operational tasks rather than application development.

It demonstrates the ability to:

```text
Identify repetitive operational task
          ↓
Automate it with Bash
          ↓
Use CLI/API interfaces
          ↓
Validate authentication
          ↓
Handle common failures
          ↓
Generate useful output
          ↓
Schedule recurring checks
          ↓
Maintain the automation with Git
```

Relevant entry-level areas include:

- Technical Support
- IT Support
- Linux Support
- Cloud Support
- AWS Support
- Infrastructure Support
- Cloud Operations
- IT Operations

---

# ⚠️ Security Notes

This project is intended for learning and portfolio purposes.

Never commit:

- AWS access keys
- AWS secret keys
- GitHub tokens
- SSH private keys
- `.env` files containing secrets
- private certificates
- production credentials

If a credential is accidentally exposed, treat it as compromised and rotate/revoke it immediately.

---

# 📚 Related Documentation

- `docs/STAGE-1.md` — detailed AWS automation documentation
- `docs/STAGE-2.md` — detailed GitHub API documentation

---

## 👨‍💻 Author

**Dhananjay Khaire**

MCA (AI & ML) Student | Cloud & DevOps Learning Track

Focus areas:

```text
Linux
AWS
Cloud Support
Bash Automation
Git/GitHub
DevOps Fundamentals
```

---

<div align="center">

**AWS Resource Tracker with GitHub API Integration**

Built as a hands-on Linux, AWS and API automation project.

</div>
