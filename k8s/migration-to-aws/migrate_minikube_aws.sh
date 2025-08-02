#!/bin/bash
set -e

# ====== CONFIGURATION ======
AWS_REGION="us-east-1"
EKS_CLUSTER_NAME="training-eks"
VELERO_USER="velero"
VELERO_PLUGIN_VERSION="v1.8.2"
# =============================

# echo "Starting Minikube → AWS EKS migration..."

# # Create S3 bucket for Velero
# VELERO_BUCKET="velero-backup-$(date +%s)"
# echo "Creating S3 bucket: $VELERO_BUCKET"
# aws s3api create-bucket \
#   --bucket $VELERO_BUCKET \
#   --region $AWS_REGION \
#   # --create-bucket-configuration LocationConstraint=$AWS_REGION

# # Create IAM user for Velero
# echo "Creating IAM user: $VELERO_USER"
# aws iam create-user --user-name $VELERO_USER || true

# aws iam attach-user-policy --user-name $VELERO_USER \
#     --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
# aws iam attach-user-policy --user-name $VELERO_USER \
#     --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess

# # Create Access Keys
# echo "Creating access keys..."
# ACCESS_KEYS=$(aws iam create-access-key --user-name $VELERO_USER)
# AWS_ACCESS_KEY_ID=$(echo $ACCESS_KEYS | jq -r '.AccessKey.AccessKeyId')
# AWS_SECRET_ACCESS_KEY=$(echo $ACCESS_KEYS | jq -r '.AccessKey.SecretAccessKey')

# Save credentials to file
CRED_FILE="./credentials-velero"
# cat > $CRED_FILE <<EOL
# [default]
# aws_access_key_id=$AWS_ACCESS_KEY_ID
# aws_secret_access_key=$AWS_SECRET_ACCESS_KEY
# EOL
# echo "AWS credentials saved to $CRED_FILE"

# # Install Velero on Minikube
# echo "Installing Velero on Minikube..."
# kubectl config use-context minikube
# velero install \
#     --provider aws \
#     --plugins velero/velero-plugin-for-aws:$VELERO_PLUGIN_VERSION \
#     --bucket $VELERO_BUCKET \
#     --backup-location-config region=$AWS_REGION \
#     --secret-file $CRED_FILE

# # Wait for Velero pod to be ready
# kubectl -n velero rollout status deploy/velero

# # # Backup Minikube workloads
# # echo "Backing up all workloads from Minikube..."        
# # # velero backup create minikube-full-backup --include-namespaces '*' --wait

# velero backup create minikube-backup --include-namespaces default --wait

# Install Velero on EKS
echo "Installing Velero on AWS EKS..."
aws eks --region $AWS_REGION update-kubeconfig --name $EKS_CLUSTER_NAME
kubectl config use-context arn:aws:eks:$AWS_REGION:$(aws sts get-caller-identity --query Account --output text):cluster/$EKS_CLUSTER_NAME

velero install \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:$VELERO_PLUGIN_VERSION \
    --bucket velero-backup-1754061620 \
    --backup-location-config region=$AWS_REGION \
    --secret-file $CRED_FILE

kubectl -n velero rollout status deploy/velero

# Restore into EKS
echo "Restoring workloads into EKS..."
velero restore create --from-backup minikube-backup --wait

echo "Migration complete!"
echo "S3 Bucket: $VELERO_BUCKET"
echo "Verify workloads with: kubectl get pods -A"
