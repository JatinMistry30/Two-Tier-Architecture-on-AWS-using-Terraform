# Two-Tier Architecture on AWS using Terraform

A complete two-tier web application architecture deployed on AWS using Terraform. This project creates a scalable web infrastructure with load balancing and a secure database tier.

## 🏗️ Architecture Overview

This project implements a classic two-tier architecture with the following components:

**Tier 1 - Web Layer (Public Subnets)**
- 2 EC2 instances (web1 and web2) across different Availability Zones
- Application Load Balancer for traffic distribution
- Public subnets with internet access via Internet Gateway

**Tier 2 - Database Layer (Private Subnets)**
- RDS MySQL 5.7 database instance
- Private subnets with no direct internet access
- Database subnet group spanning multiple AZs

```
Internet → ALB → [EC2 web1, EC2 web2] → RDS MySQL
           ↓
    Public Subnets (ap-south-1a, ap-south-1b)
           ↓
    Private Subnets (ap-south-1a, ap-south-1b)
```

## 📦 Infrastructure Components

### Network Resources (`network_resources.tf`)
- **VPC**: Custom VPC with CIDR `10.0.0.0/16`
- **Public Subnets**: 
  - `public-1`: `10.0.1.0/24` in `ap-south-1a`
  - `public-2`: `10.0.2.0/24` in `ap-south-1b`
- **Private Subnets**:
  - `private-1`: `10.0.3.0/24` in `ap-south-1a`
  - `private-2`: `10.0.4.0/24` in `ap-south-1b`
- **Internet Gateway**: For public subnet internet access

### Route Table Resources (`routetable_resource.tf`)
- **Public Route Table**: Routes traffic to Internet Gateway
- **Route Table Associations**: Links public subnets to the route table

### EC2 Resources (`ec2_resources.tf`)
- **Web Server 1**: t2.micro instance in ap-south-1a
- **Web Server 2**: t2.micro instance in ap-south-1b
- **AMI Used**: `ami-0287a05f0ef0e9d9a` (Amazon Linux)
- **Key Pair**: `twotier-key-pair` (must exist in your AWS account)

### Database Resources (`db_resources.tf`)
- **RDS Instance**: 
  - Engine: MySQL 5.7
  - Instance Class: db.t2.micro
  - Storage: 5 GB
  - Database Name: `project_db`
  - Username: `admin`
  - Password: `password` ⚠️
- **DB Subnet Group**: Spans both private subnets

### Security Resources (`security_resource.tf`)
- **Application Load Balancer**: Distributes traffic between web servers
- **Target Group**: Health checks and routing for EC2 instances
- **ALB Listener**: HTTP traffic on port 80

### Security Groups
- **Public Security Group** (`public_sg`):
  - Inbound: HTTP (80), SSH (22) from anywhere
  - Outbound: All traffic allowed
- **Private Security Group** (`private_sg`):
  - Inbound: MySQL (3306) from VPC and public security group, SSH (22) from anywhere
  - Outbound: All traffic allowed
- **ALB Security Group** (`alb_sg`):
  - Inbound/Outbound: All traffic (⚠️ overly permissive)

## 🚀 Deployment Instructions

### Prerequisites
- AWS CLI configured with appropriate credentials
- Terraform installed (version ~> 4.16 AWS provider)
- An existing EC2 Key Pair named `twotier-key-pair` in ap-south-1 region

### Steps

1. **Clone the repository**
```bash
git clone https://github.com/JatinMistry30/Two-Tier-Architecture-on-AWS-using-Terraform.git
cd Two-Tier-Architecture-on-AWS-using-Terraform
```

2. **Initialize Terraform**
```bash
terraform init
```

3. **Review the plan**
```bash
terraform plan
```

4. **Deploy the infrastructure**
```bash
terraform apply
```

5. **Confirm deployment**
Type `yes` when prompted.

## 📁 File Structure
```
├── provider.tf              # AWS provider configuration
├── network_resources.tf     # VPC, subnets, Internet Gateway
├── routetable_resource.tf   # Route tables and associations
├── ec2_resources.tf         # EC2 instances (web servers)
├── db_resources.tf          # RDS MySQL database
├── security_resource.tf     # ALB, target groups, and ALB security group
└── README.md               # This file
```

## 🔧 Configuration Details

### Region and Availability Zones
- **Region**: ap-south-1 (Asia Pacific - Mumbai)
- **AZs**: ap-south-1a and ap-south-1b

### Instance Specifications
- **EC2 Instances**: t2.micro (Free Tier eligible)
- **RDS Instance**: db.t2.micro (Free Tier eligible)
- **Storage**: 5 GB allocated storage for RDS

## 🌐 Accessing Your Application

After deployment:
1. **Load Balancer**: Access your application via the ALB DNS name
2. **Direct EC2 Access**: SSH to instances using their public IPs and `twotier-key-pair`
3. **Database**: Connect from EC2 instances using the RDS endpoint

To get the ALB DNS name:
```bash
terraform output
# or check AWS Console → EC2 → Load Balancers
```

## ⚠️ Security Considerations

**Current Security Issues to Address:**

1. **Database Password**: Hardcoded password should be moved to AWS Secrets Manager or variables
2. **ALB Security Group**: Too permissive (allows all traffic)
3. **SSH Access**: Consider restricting SSH access to specific IP ranges
4. **Database Public Access**: Correctly set to false ✅

### Recommended Improvements

```hcl
# Move to variables.tf
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

# Update ALB security group
resource "aws_security_group" "alb_sg" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

## 💰 Cost Estimation

**Monthly costs (approximate):**
- EC2 instances (2 × t2.micro): $8.50/month (Free Tier: $0)
- RDS (db.t2.micro): $12.00/month (Free Tier: $0)
- Load Balancer: $16.20/month
- **Total**: ~$36.70/month (or ~$16.20 with Free Tier)

## 🧹 Cleanup

To destroy all resources:
```bash
terraform destroy
```

**Important**: This will permanently delete all resources including the database.

## 📊 Outputs

Consider adding an `outputs.tf` file:
```hcl
output "load_balancer_dns" {
  value = aws_lb.project_alb.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.project-db.endpoint
}

output "web1_public_ip" {
  value = aws_instance.web1.public_ip
}

output "web2_public_ip" {
  value = aws_instance.web2.public_ip
}
```

## 🔧 Troubleshooting

### Common Issues

1. **Key pair not found**: Create `twotier-key-pair` in ap-south-1 region
2. **Insufficient permissions**: Ensure your AWS credentials have EC2, RDS, and VPC permissions
3. **Resource limits**: Check AWS service quotas in ap-south-1 region

### Terraform State Issues

If you encounter the large file error again:
```bash
# Ensure .gitignore contains:
echo ".terraform/" >> .gitignore
echo "*.tfstate*" >> .gitignore
echo ".terraform.lock.hcl" >> .gitignore
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📞 Support

For issues and questions:
- Create an issue in the [GitHub repository](https://github.com/JatinMistry30/Two-Tier-Architecture-on-AWS-using-Terraform/issues)
- Contact: [Jatin Mistry](https://github.com/JatinMistry30)

---

**Built by [Jatin Mistry](https://github.com/JatinMistry30)** | **Region**: ap-south-1 | **Provider**: AWS ~> 4.16