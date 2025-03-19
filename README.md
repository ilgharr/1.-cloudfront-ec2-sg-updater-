# **EC2 Security Group IP Range Updater**

## **Description**
This Bash script automatically updates the security groups of an EC2 instance with the latest IP prefixes provided by AWS. It ensures that the security group rules are updated dynamically and can handle AWS security group rule limits by creating additional security groups as needed.

## **Features**
- Fetches the latest AWS IP ranges directly from AWS using a JSON file.
- Dynamically assigns IP ranges to the specified EC2 instance’s security groups.
- Automatically creates and attaches new security groups as needed when the rule limit per security group is exceeded.
- Prevents duplicate rules by checking existing security group configurations.

---

## **Requirements**

Before you run the script, ensure the following dependencies and permissions are set up:

### **Installed Tools**
1. **AWS CLI (Command Line Interface)**  
   - Install the AWS CLI and configure it with your credentials:
     ```bash
     sudo yum install aws-cli  # On Amazon Linux
     aws configure
     ```

2. **`jq` (JSON parser)**  
   - Used to parse the `ip-ranges.json` file:
     ```bash
     sudo yum install jq
     ```

3. **`curl` (for downloading the IP ranges)**  
   - The script uses `curl` to pull the `ip-ranges.json` file:
     ```bash
     sudo yum install curl
     ```

### **AWS IAM Permissions**
The IAM user or role running the script must have the following permissions:
- `ec2:DescribeInstances`
- `ec2:DescribeSecurityGroups`
- `ec2:CreateSecurityGroup`
- `ec2:AuthorizeSecurityGroupIngress`
- `ec2:ModifyInstanceAttribute`

These permissions are required for the script to:
- Fetch information about your EC2 instance and existing security groups.
- Create, attach, and update security groups with new rules.

---

## **Installation and Usage**

1. **Clone the Repository**
   Clone this repository to your local machine:
   ```bash
   git clone git@github.com:ilgharr/cloudfront-ec2-sg-updater.git
   cd cloudfront-ec2-sg-updater
   ```

2. **Set Execute Permissions**
   Ensure the script has execute permissions:
   ```bash
   chmod +x add_cloudfront_ipranges.sh
   ```

3. **Download the IP Ranges**
   Use `curl` to download the latest `ip-ranges.json` file provided by AWS:
   ```bash
   curl -o ip-ranges.json https://ip-ranges.amazonaws.com/ip-ranges.json
   ```
   This file contains all AWS service IP ranges.

4. **Edit the Script**
   Open the script in any text editor and replace the placeholders with your own values:
   - Replace the **`INSTANCE_ID`** with the ID of your EC2 instance:
     ```bash
     INSTANCE_ID="i-xxxxxxxxxxxxxxxxx"  # Example: i-0123456789abcdef0
     ```
   - Replace the **`VPC_ID`** with the ID of your VPC:
     ```bash
     VPC_ID="vpc-xxxxxxxxxxxxxxxxx"  # Example: vpc-01234567
     ```

5. **Run the Script**
   After configuring the script, execute it using the following command:
   ```bash
   ./add_cloudfront_ipranges.sh
   ```

---

## **Example Output**

On a successful run, the script will output:

Added IP range: 120.52.22.96/27  
Added IP range: 205.251.249.0/24  
Added IP range: 180.163.57.128/26  
Added IP range: 204.246.168.0/22  
Added IP range: 111.13.171.128/26  
Added IP range: 18.160.0.0/15  
Added IP range: 205.251.252.0/23  
Added IP range: 54.192.0.0/16  
Added IP range: 204.246.173.0/24  
Added IP range: 54.230.200.0/21  
