#!/bin/bash
set -e

# ====== CONFIGURE ======
AWS_REGION="us-east-1"
VELERO_USER="velero"
VELERO_BUCKET="velero-backup-1754061620" 
# =======================

if [ -z "$VELERO_BUCKET" ]; then
    echo "Please set VELERO_BUCKET to the S3 bucket name from your previous migration run."
    exit 1
fi

echo "🧹 Starting cleanup of previous migration..."

# Remove Velero from Minikube
echo "Removing Velero from Minikube..."
kubectl config use-context minikube || true
kubectl delete namespace velero --ignore-not-found=true

# Remove Velero from AWS EKS
echo "Removing Velero from AWS EKS..."
aws eks --region $AWS_REGION update-kubeconfig --name training-eks || true
# kubectl delete namespace velero --ignore-not-found=true

# Delete S3 bucket
echo "Deleting S3 bucket: $VELERO_BUCKET..."
aws s3 rb s3://$VELERO_BUCKET --force || true

# Delete IAM user & access keys
echo "Deleting IAM user: $VELERO_USER..."
ACCESS_KEYS=$(aws iam list-access-keys --user-name $VELERO_USER --query 'AccessKeyMetadata[*].AccessKeyId' --output text 2>/dev/null)
for key in $ACCESS_KEYS; do
    aws iam delete-access-key --access-key-id "$key" --user-name $VELERO_USER || true
done

aws iam detach-user-policy --user-name $VELERO_USER --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess || true
aws iam detach-user-policy --user-name $VELERO_USER --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess || true
aws iam delete-user --user-name $VELERO_USER || true

# Delete local Velero credentials file
echo "Removing local credentials file..."
rm -f ./credentials-velero

echo "Cleanup complete!"
