#!/bin/bash

# Configurable variables
JSON_FILE="ip-ranges.json"
INSTANCE_ID="i-xxxxxxxxxxxxxxxxx"  # Replace with your EC2 instance ID
PROTOCOL="tcp"
PORT="80"
MAX_RULES=60  # Security Group Rule Limit (default is 60, but this can vary based on AWS settings)
SECURITY_GROUP_PREFIX="CLOUDFRONT-SG"  # Prefix for new security group names
VPC_ID="vpc-xxxxxxxxxxxxxxxxx"  # Replace with your VPC ID


create_security_group() {
    local suffix="$1"
    local new_sg_name="${SECURITY_GROUP_PREFIX}-$suffix"
    local new_sg_id=$(aws ec2 create-security-group --group-name "$new_sg_name" \
        --description "Security group for CloudFront IPs (part $suffix)" \
        --vpc-id "$VPC_ID" --query "GroupId" --output text)

    if [ -z "$new_sg_id" ]; then
        echo "Error: Failed to create a new security group."
        exit 1
    fi

    # Attach security group to instance
    local current_groups=$(aws ec2 describe-instances --instance-id "$INSTANCE_ID" \
        --query "Reservations[0].Instances[0].SecurityGroups[*].GroupId" --output text)

    aws ec2 modify-instance-attribute --instance-id "$INSTANCE_ID" \
        --groups $current_groups "$new_sg_id" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: Failed to attach security group $new_sg_id to instance."
        exit 1
    fi

    echo "$new_sg_id"
}

# Initialize
sg_suffix=1
current_sg_id=$(create_security_group "$sg_suffix")
rule_count=0

# Read IP ranges
# Use the line below to specify region
#IP_RANGES=($(jq -r '.prefixes[] | select(.service=="CLOUDFRONT" and .region=="GLOBAL").ip_prefix' "$JSON_FILE"))

IP_RANGES=($(jq -r '.prefixes[] | select(.service=="CLOUDFRONT").ip_prefix' "$JSON_FILE"))

for IP_RANGE in "${IP_RANGES[@]}"; do
    if [ "$rule_count" -ge "$MAX_RULES" ]; then
        sg_suffix=$((sg_suffix + 1))
        current_sg_id=$(create_security_group "$sg_suffix")
        rule_count=0
    fi

    existing_rule=$(aws ec2 describe-security-groups --group-ids "$current_sg_id" \
        --query "SecurityGroups[0].IpPermissions[?FromPort==\`$PORT\` && ToPort==\`$PORT\` && IpProtocol==\`$PROTOCOL\`].IpRanges[?CidrIp==\`$IP_RANGE\`]" \
        --output text)

    if [ -z "$existing_rule" ]; then
        aws ec2 authorize-security-group-ingress --group-id "$current_sg_id" \
            --protocol "$PROTOCOL" --port "$PORT" --cidr "$IP_RANGE" >/dev/null 2>>error.log
        if [ $? -eq 0 ]; then
            echo "Added IP range: $IP_RANGE"
            rule_count=$((rule_count + 1))
        else
            echo "Failed to add $IP_RANGE. Check error.log."
        fi
    else
        echo "IP range $IP_RANGE exists in $current_sg_id. Skipping."
    fi
done

echo "Finished."
