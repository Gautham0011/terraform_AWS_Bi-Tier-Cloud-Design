# Terraform AWS Bi-Tier Cloud Design

A scalable and Highly available bi-tier web application architecture deployed on AWS using Terraform.

## Architecture Overview

This project implements a bi-tier architecture on AWS featuring:

- **Presentation Tier**: Auto Scaling Group with Application Load Balancer
- **Data Tier**: Amazon RDS MySQL database with Multi-AZ deployment
- **Networking**: Custom VPC with public/private subnets across multiple AZs
- **Security**: Security groups, NACLs, and proper IAM roles
- **High Availability**: Multi-AZ deployment with automated failover

![Web Server Status - Instance 1](images/server-status-1.png)
*Web Server Status showing Primary Database connection*

![Web Server Status - Instance 2](images/server-status-2.png)
*Web Server Status showing Replica Database in different AZ*

## Key Components

### Networking
- **VPC**: Custom Virtual Private Cloud with CIDR block
- **Subnets**: Public and private subnets across multiple Availability Zones
- **Internet Gateway**: For internet access to public subnets
- **Route Tables**: Proper routing configuration

### Compute
- **Auto Scaling Group (ASG)**: Automatically scales EC2 instances based on demand
- **Launch Template**: Defines instance configuration
- **Application Load Balancer (ALB)**: Distributes traffic across healthy instances
- **Security Groups**: Firewall rules for web servers and database

### Database
- **Amazon RDS**: MySQL database with Multi-AZ deployment
- **DB Subnet Group**: Spans multiple AZs for high availability
- **Automated Backups**: Point-in-time recovery enabled
- **Replica**: For improved HA

## Prerequisites

### 1. Install Terraform

- **Steps Based on operating system**: [Terraform Installation](https://developer.hashicorp.com/terraform/install)

**Official Documentation**: [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

### 2. AWS CLI Configuration
Configure AWS credentials:
```bash
aws configure
```

### 3. Create SSH Key Pair (Optional)
1. Go to AWS Console → EC2 → Key Pairs
2. Create a new key pair
3. Download the private key file (.pem)
4. Store it securely (needed for SSH access to EC2 instances if required)
5. Use as follows if you need to ssh (NOTE - Additionally need to allow inbound connectivity from your local IP in Private Security group for port 22)

```hcl
❯ ssh -i <path to you secret kry> ec2-user@<public IP>
```

**Note**: SSH access is not mandatory for this setup but recommended for troubleshooting.

### 4. Database Password Configuration
Create a `secret.tfvars` file in the project root:
```hcl
db_password = "your-secure-database-password"
```

**Important**: 
- Never commit `secret.tfvars` to version control
- Use a strong password (minimum 8 characters with mixed case, numbers, and symbols)
- Alternatively, you'll be prompted to enter the password during `terraform plan` or `terraform apply`

## Deployment Instructions

### Step 1: Create Remote Backend Infrastructure

First, deploy the remote backend infrastructure to store Terraform state files securely:

```bash
cd remote-backend/
terraform init
terraform plan
terraform apply
```

This creates:
- S3 bucket for state storage
- DynamoDB table for state locking

### Step 2: Deploy Main Infrastructure

Navigate back to the main project directory and deploy the bi-tier architecture:

```bash
cd ../setup/
terraform init
terraform plan -var-file="secret.tfvars"
terraform apply -var-file="secret.tfvars"
```

**Alternative** (if you prefer to enter password interactively):
```bash
terraform init
terraform plan
terraform apply
```

### Step 3: Access Your Application

After successful deployment:

1. **Get the Load Balancer URL**: 
   - Check the Terraform output for `ELB_DNS`
   - Example output: `elb-dns = "dual-tier-project-alb-736273417.us-east-1.elb.amazonaws.com/"`

2. **Access the Application**:
   - Open your web browser
   - Navigate to: `http://[ELB_DNS_OUTPUT]`
   - You should see the web server status page similar to the screenshots above

## Quick Start Commands

```bash
# Step 1: Setup remote backend
cd remote-backend/
terraform init
terraform apply

# Step 2: Deploy main infrastructure
cd ../setup
terraform init
terraform plan -var-file="secret.tfvars"
terraform apply -var-file="secret.tfvars"

# Step 3: Get the ELB DNS from output and browse to it
# Output: ELB_DNS = "your-load-balancer-dns"
```

## Infrastructure Components Details

### Module Configuration

- **Auto Scaling Group**: ASG with autoscalaing facility based on traffic peak hours
- **Load Balancer**: Backend public traffic to ASG
- **Networking**: Setup AWS VPC for the bi-tier project
- **Security Groups**: Security groups with minimal required access
- **Database**: HA MySQL DB setup from two subnets of the same region but different AZ



## Cleanup Instructions

**⚠️ Important**: Follow this exact order to avoid issues with state files.

### Step 1: Destroy Main Infrastructure
```bash
cd setup/
terraform destroy -var-file="secret.tfvars"
```

### Step 2: Destroy Remote Backend
```bash
cd remote-backend/
terraform destroy
```

## Troubleshooting

### Common Issues

1. **Permission Errors**: Ensure your AWS credentials have necessary permissions for EC2, RDS, VPC, and IAM operations.

2. **Resource Limits**: Check your AWS service quotas (in case of free account) if resources fail to create.

3. **Database Connection Issues**: Verify security group rules allow communication between web servers and database.

4. **Load Balancer Health Checks**: Ensure your web application responds correctly to health check requests.

5. export required AWS creds before beggining the terraform actions like
```bash
export AWS_ACCESS_KEY_ID=<key_id> && 
export AWS_SECRET_ACCESS_KEY=<secret> && 
export AWS_DEFAULT_REGION=us-east-1
```

### SSH Access (If Needed)
If you need to troubleshoot EC2 instances:
```bash
ssh -i /path/to/your-key.pem ec2-user@[instance-public-ip]
```

**Tip**: Use AWS Cost Explorer and set up billing alerts to monitor your usage.

## Architecture Diagram

```
Internet
    |
    v
Application Load Balancer (ALB)
    |
    v
Auto Scaling Group
    |
    +-- EC2 Instance (AZ-1a) -- Web Server
    |
    +-- EC2 Instance (AZ-1b) -- Web Server
    |
    v
Private Subnets
    |
    v
RDS MySQL (Multi-AZ)
    |
    +-- Primary DB (AZ-1a)
    |
    +-- Standby DB (AZ-1b)
```

## File Structure

```
❯ tree two_tier
two_tier
├── modules
│   ├── auto_scaling
│   │   ├── main.tf
│   │   ├── output.tf
│   │   ├── user_data.sh
│   │   └── variables.tf
│   ├── database
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── variables.tf
│   ├── load_balancer
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── variables.tf
│   ├── networking
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── variables.tf
│   └── security_groups
│       ├── main.tf
│       ├── output.tf
│       └── variables.tf
├── README.md
├── remote_backend_infra
│   ├── main.tf
│   ├── output.tf
│   ├── provider.tf
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   └── variables.tf
├── setup
│   ├── backend.tf
│   ├── main.tf
│   ├── output.tf
│   ├── provider.tf
│   ├── terraform.tfvars
│   └── variables.tf
|   └── secret.tfvars (create this)
└── terraform.tfstate

9 directories, 30 files
```
---

**⚠️ Important Reminders**:
- Always review the `terraform plan` output before applying
- Keep your `secret.tfvars` file secure and never commit it
- Monitor your AWS costs regularly
- Follow the cleanup instructions when you're done testing
- You will get an output at the end of the code run "ELB_DNS". Use that as URL on your browser