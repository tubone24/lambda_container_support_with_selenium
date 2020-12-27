# lambda_container_support_with_selenium

[![license](https://img.shields.io/github/license/tubone24/lambda_container_support_with_selenium.svg)](LICENSE)
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

> Lambda Container Support, use selenium, use terraform

This is Creating a template that runs Selenium from Alpine container and deploying **Lambda - Container Image Support** and applying it with Terraform

## Table of Contents

- [Background](#background)
- [Install](#install)
- [Usage](#usage)
- [License](#license)

## Background

In our company, we have a lot of Slack workSpaces.

In addition, we also post an attendance to Slack, but it's a bit of a hassle to post everything to all the different workSpaces.

Then, it seems that we can solve this problem by using Slack API and mutual posting, but I heard that some WorkSpace prohibits external linkage for security reasons. What the heck...

So, if we take a screenshot of the secure Slack and post it to the Slack we usually use, at least we've communicated, so it'll be easy! So let's make it.

![img](https://i.imgur.com/odKSxHU.png)

[More information? Go to my Article: ]()

### Architects

Use Lambda in VPC to create a Lambda with a fixed global IP address, and push the Docker Image to the ECR.

Also, for security reasons, the login password to Slack will be encrypted using AWS KMS.

![img](https://i.imgur.com/GPamgYL.png)

## Install

### System Requirements

- Terraform v0.12 or more
- Make
- Docker
- Python 3.7

### Preconditions

This tool used by Terraform, Make, Python and Docker.

So, Install those apps before run this tool.

#### Quick Install

With my [mac-auto-setup](https://github.com/tubone24/mac-auto-setup), you can build the environment you need for your Mac.

#### Set up your environment

When executing the container, you need to specify the following environment variable.

Write your environments to your tfvars.

|                          |                                                                      |                                                     | 
| ------------------------ | -------------------------------------------------------------------- | --------------------------------------------------- | 
| Name                     | Meaning                                                              | Ex                                                  | 
| SLACK_TOKEN              | Need to uploading the screenshot using Slack API                     | xnob-xxxxxx                                         | 
| SLACK_CHANNEL_ID         | Channel id where you want to upload the screenshot(not channel name) | C01SJAKESAD                                         | 
| SLACK_USERNAME           | Slack account login email                                            | example@hoge.com                                    | 
| SLACK_PASSWORD           | Slack account login password                                         | KMS encoded password                                | 
| SLACK_LOGIN_URL          | Slack login URL                                                      | https://hoge-hoge.slack.com                         | 
| SLACK_ATTEND_CHANNEL_URL | Screenshot point url                                                 | https://app.slack.com/client/XXXXXXXXXX/XXXXXXXXXXX | 

In addition, set the security group id and subnet id to configure Lambda in VPC.

```
$ cp terraform/tfvars.tfvars.tpl env.tfvars
$ vi terraform/env.tfvars

$ cp terraform/ecr/tfvars.tfvars.tpl env.tfvars
$ vi terraform/ecr/env.tfvars
```

### Build Container Image

The following commands should be executed in the project root.

```
make build-push-image ENV=env
```

### Deploy

The following commands should be executed in the project root.

First, Create ECR Repository

```
make backend ENV=env

make remote-enable-ecr ENV=env

make create-env-ecr ENV=env

make plan-ecr ENV=env

make apply-ecr ENV=env
```

Second, Deploy Lambda

```
make remote-enable ENV=env

make create-env ENV=env

make plan ENV=env

make apply ENV=env
```

## Usage

Post a screenshot of the Slack attend channel to Slack at a set time each day.

![img](https://i.imgur.com/oHtRLCO.png)


## License

[MIT © tubone24](LICENSE)
