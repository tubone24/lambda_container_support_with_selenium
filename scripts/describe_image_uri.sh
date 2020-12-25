#!/usr/bin/env bash

ACCOUNT_ID=$1
ECR_REPO_NAME=$2
REGION="ap-northeast-1"

image_id_digest=$(aws ecr describe-images --repository-name "${ECR_REPO_NAME}" --image-ids imageTag=latest | jq ".imageDetails[].imageDigest")
echo "$ACCOUNT_ID".dkr.ecr.$REGION.amazonaws.com/"$ECR_REPO_NAME"@"$(echo "$image_id_digest" | tr -d '"')"