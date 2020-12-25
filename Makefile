ENV = $1
ARGS = $2
CD = cd terraform
CD_ECR = cd terraform/ecr
BUCKET_NAME = attend-selenium-${ENV}-lambda-tfstate
VARS = ${ENV}.tfvars
PROFILE = ${ENV}
AWS = $(shell ls -a ~/ | grep .aws)
ECR_REPO_NAME = "otsubo-test"

ACCOUNT_ID = $(shell grep "account_id" terraform/${ENV}.tfvars | sed -e 's/account_id = "//g' | tr -d '"' )

IMAGE_URI = $(shell ./scripts/describe_image_uri.sh ${ACCOUNT_ID} ${ECR_REPO_NAME})

$(warning IMAGE_URI = $(IMAGE_URI))

build-push-image:
	sh ./scripts/build_and_push.sh ${ENV} ${ACCOUNT_ID} ${ECR_REPO_NAME}

backend:
ifeq ($(AWS),.aws)
	aws s3api create-bucket --bucket ${BUCKET_NAME} --create-bucket-configuration LocationConstraint=ap-northeast-1 --profile ${PROFILE}
else
	aws s3api create-bucket --bucket ${BUCKET_NAME} --create-bucket-configuration LocationConstraint=ap-northeast-1
endif

tf:
	@${CD} && \
		terraform workspace select ${PROFILE} && \
		terraform ${ARGS} \
		-var-file=${VARS}

create-env:
	@${CD} && \
		terraform workspace new ${PROFILE}

remote-enable:
	@${CD} && \
		terraform init \
		-input=true \
		-reconfigure \
		-backend-config "bucket=${BUCKET_NAME}" \
		-backend-config "profile=${PROFILE}"

import:
	@${CD} && \
		terraform workspace select ${PROFILE} && \
		terraform import  \
		-var-file=${VARS} \
		${ARGS}

plan:
	@${CD} && \
		terraform workspace select ${PROFILE} && \
		terraform plan ${ARGS} \
		-var-file=${VARS} \
		-var 'image_uri=${IMAGE_URI}'

apply:
	@${CD} && \
		terraform workspace select ${PROFILE} && \
		terraform apply -auto-approve ${ARGS} \
		-var-file=${VARS} \
		-var 'image_uri=${IMAGE_URI}'

remote-enable-ecr:
	@${CD_ECR} && \
		terraform init \
		-input=true \
		-reconfigure \
		-backend-config "bucket=${BUCKET_NAME}" \
		-backend-config "profile=${PROFILE}"

create-env-ecr:
	@${CD_ECR} && \
		terraform workspace new ${PROFILE}

plan-ecr:
	@${CD_ECR} && \
		terraform workspace select ${PROFILE} && \
		terraform plan ${ARGS} \
		-var-file=${VARS} \
		-var "repo_name=${ECR_REPO_NAME}"

apply-ecr:
	@${CD_ECR} && \
		terraform workspace select ${PROFILE} && \
		terraform apply -auto-approve ${ARGS} \
		-var-file=${VARS} \
		-var "repo_name=${ECR_REPO_NAME}"