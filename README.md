# terraform_AWS_Bi-Tier-Cloud-Design

# Terraform AWS Bi-Tier Cloud Design

A scalable and secure bi-tier web application architecture deployed on AWS using Terraform Infrastructure as Code (IaC).

## Architecture Overview

This project implements a robust bi-tier architecture on AWS featuring:

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
- **NAT Gateway**: For outbound internet access from private subnets
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
- **Read Replica**: For improved read performance (if configured)

## Prerequisites

### 1. Install Terraform
Choose your operating system and follow the installation guide:

- **Windows**: [Terraform Windows Installation](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform)
- **macOS**: 
  ```bash
  brew tap hashicorp/tap
  brew install hashicorp/tap/terraform
  ```
- **Linux (Ubuntu/Debian)**:
  ```bash
  wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
  sudo apt update && sudo apt install terraform
  ```

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
- Proper IAM policies

### Step 2: Deploy Main Infrastructure

Navigate back to the main project directory and deploy the bi-tier architecture:

```bash
cd ../
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
   - Example output: `elb-dns = "my-alb-1234567890.us-east-1.elb.amazonaws.com"`

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
cd ../
terraform init
terraform plan -var-file="secret.tfvars"
terraform apply -var-file="secret.tfvars"

# Step 3: Get the ELB DNS from output and browse to it
# Output: ELB_DNS = "your-load-balancer-dns"
```

## Infrastructure Components Details

### Auto Scaling Configuration
- **Min Size**: 2 instances
- **Max Size**: 6 instances
- **Desired Capacity**: 2 instances
- **Health Check Type**: ELB
- **Health Check Grace Period**: 300 seconds

### Database Configuration
- **Engine**: MySQL 8.0
- **Instance Class**: db.t3.micro (free tier eligible)
- **Multi-AZ**: Enabled for high availability
- **Backup Retention**: 7 days
- **Storage**: 20 GB GP2 with auto-scaling enabled

### Security Features
- Security groups with minimal required access
- Database in private subnets only
- Web servers in public subnets behind load balancer
- Network ACLs for additional security layer

## Monitoring and Maintenance

The deployed infrastructure includes:
- CloudWatch monitoring for all resources
- Auto Scaling policies based on CPU utilization
- Load balancer health checks
- RDS automated backups

## Cleanup Instructions

**⚠️ Important**: Follow this exact order to avoid issues with state files.

### Step 1: Destroy Main Infrastructure
```bash
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

2. **Resource Limits**: Check your AWS service quotas if resources fail to create.

3. **Database Connection Issues**: Verify security group rules allow communication between web servers and database.

4. **Load Balancer Health Checks**: Ensure your web application responds correctly to health check requests.

### SSH Access (If Needed)
If you need to troubleshoot EC2 instances:
```bash
ssh -i /path/to/your-key.pem ec2-user@[instance-public-ip]
```

## Cost Considerations

This infrastructure uses several AWS resources that may incur costs:
- EC2 instances (t3.micro eligible for free tier)
- RDS database (db.t3.micro eligible for free tier)
- Application Load Balancer (~$22/month)
- NAT Gateway (~$45/month)
- Data transfer charges

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
terraform_AWS_Bi-Tier-Cloud-Design/
├── README.md
├── main.tf
├── variables.tf
├── outputs.tf
├── secret.tfvars (create this)
├── remote-backend/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── images/
    ├── server-status-1.png
    └── server-status-2.png
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Security Best Practices

- Regularly update AMIs and apply security patches
- Use AWS Systems Manager Session Manager instead of SSH when possible
- Implement proper IAM roles and policies
- Enable AWS CloudTrail for audit logging
- Use AWS Config for compliance monitoring

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review AWS documentation
3. Open an issue in this repository
4. Consult AWS support if needed

---

**⚠️ Important Reminders**:
- Always review the `terraform plan` output before applying
- Keep your `secret.tfvars` file secure and never commit it
- Monitor your AWS costs regularly
- Follow the cleanup instructions when you're done testing
- You will get an output at the end of the code run "ELB_DNS". Use that as URL on your browser