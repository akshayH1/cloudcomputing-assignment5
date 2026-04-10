#!/bin/bash
# Stop execution if any command fails
set -e

echo "1. Deleting the existing broken stack..."
aws cloudformation delete-stack \
  --stack-name personal-paas \
  --region us-west-2

echo "Waiting for stack deletion to complete (this may take a few minutes)..."
aws cloudformation wait stack-delete-complete \
  --stack-name personal-paas \
  --region us-west-2
echo "✅ Old stack deleted successfully."

echo "2. Creating the new stack..."
aws cloudformation create-stack \
  --stack-name personal-paas \
  --template-body file://template.yaml \
  --parameters ParameterKey=KeyName,ParameterValue=assignment4 \
  --region us-west-2 \
  --capabilities CAPABILITY_NAMED_IAM

echo "Waiting for the new stack to be ready (this will take a few minutes)..."
aws cloudformation wait stack-create-complete \
  --stack-name personal-paas \
  --region us-west-2
echo "✅ New stack created successfully."

echo "3. Fetching the new EC2 Public IP address..."
EC2_IP=$(aws cloudformation describe-stacks \
  --stack-name personal-paas \
  --query "Stacks[0].Outputs[0].OutputValue" \
  --output text \
  --region us-west-2)
echo "✅ New EC2 IP is: $EC2_IP"

echo "4. Updating Git remote..."
cd myapp
# Remove the old 'paas' remote so we can add the new IP
git remote remove paas 2>/dev/null || true
git remote add paas ubuntu@"$EC2_IP":/home/ubuntu/app.git
echo "✅ Git remote updated."

echo "5. Pushing code to trigger deployment..."
GIT_SSH_COMMAND='ssh -i "../../cloudcomputing-assignment4/assignment4.pem" -o StrictHostKeyChecking=accept-new' \
git push paas main

echo "🎉 Deployment triggered! Wait a few seconds and then test your app at:"
echo "http://$EC2_IP"