# AWS Windows EC2 Terraform Infrastructure

This repository contains Terraform configuration to deploy a Windows EC2 instance in AWS with an additional EBS volume, complete networking setup, and security configurations.

## Prerequisites

Before you begin, ensure you have:

1. [Terraform](https://www.terraform.io/downloads.html) (version 0.12 or later) installed
2. [AWS CLI](https://aws.amazon.com/cli/) installed and configured
3. AWS credentials configured (`aws configure`)
4. PowerShell (for Windows users)

## Infrastructure Components

This Terraform configuration creates:

- VPC with public subnet
- Internet Gateway
- Route Table
- Security Group (allowing RDP, HTTP, and HTTPS)
- Windows EC2 instance (t3.medium)
- 100GB EBS volume (additional storage)
- RSA key pair for instance access

## Quick Start

1. Clone this repository:
   
  $ git clone <repository-url>
  $ cd <repository-name>
   

2. Initialize Terraform:
 
  $ terraform init
 

3. Review the planned changes:
   
   $ terraform plan
   

4. Apply the configuration:
   
   $ terraform apply
   

5. After successful deployment, you'll receive:
   - The public IP of your EC2 instance
   - Location of your private key file (in the `keys` folder)

## Connecting to the Instance

1. Locate your private key in the `keys` folder (harsha-key.pem)
2. Use the public IP displayed in the outputs
3. Connect using Remote Desktop Protocol (RDP) on port 3389
4. Use the Windows default administrator credentials

## Security Features

- VPC isolation
- Security group with minimal required ports
- Encrypted root volume
- Encrypted additional EBS volume
- Private key stored securely with read-only permissions


## Clean Up

To destroy all created resources:

 $ terraform destroy


## Additional Notes

- The Windows AMI used is for us-west-2 region
- Default instance type is t3.medium
- Root volume is 50GB
- Additional EBS volume is 100GB
- All volumes are encrypted by default

## Configuration Customization

To modify the configuration:

1. Update `main.tf` with your preferred:
   - Region
   - Instance type
   - Volume sizes
   - CIDR blocks
   - Security group rules

2. Re-run `terraform apply` to apply changes

## Troubleshooting

1. If key creation fails:
   - Ensure you have write permissions in the current directory
   - Check if the keys directory exists and is accessible

2. If instance creation fails:
   - Verify your AWS credentials
   - Check if you have sufficient permissions
   - Ensure the AMI ID is available in your region


