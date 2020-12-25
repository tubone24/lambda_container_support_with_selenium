#!/usr/bin/env bash

ENV=$1
ACCOUNT_ID=$2
ECR_REPO_NAME=$3
REGION="ap-northeast-1"
IMAGE_NAME="attend_selenium"

aws ecr get-login-password --region $REGION --profile "$ENV" | docker login --username AWS --password-stdin "$ACCOUNT_ID".dkr.ecr.$REGION.amazonaws.com
docker build -t $IMAGE_NAME .
docker tag $IMAGE_NAME:latest "$ACCOUNT_ID".dkr.ecr.$REGION.amazonaws.com/"$ECR_REPO_NAME":latest
docker push "$ACCOUNT_ID".dkr.ecr.$REGION.amazonaws.com/"$ECR_REPO_NAME":latest