# Orchestration approach for hygieia devops dashboard

## What's this ?

Hygieia is a dashboard UI connecting external services (controllers) to gather useful information for devops teams. This project is explaining how to implement CI/CD on top of this development.

## Technologies involved

* java
* git
* maven
* jenkins
* docker
* nodejs
* mongodb
* bower
* gulp
* aws

## The approach

### Infrastructure idea

Build 4 cloud boxes to orchestrate the code push cycle

* jenkins-1
* docker-registry-1
* docker-web-1
* docker-web-2

### Pre-requirements

### Getting familiar with Hygieia architecture

Before any continuous implementation is set, a clear understanding of all its pieces is needed. Next I'm going to install a fully working instance step by step.

## Building API+UI project with AWS ec2

A base ubuntu 16 image as IaC with CloudFormation + all dependencies stack provisioned with puppet.

    aws cloudformation create-stack  --stack-name hygieia-box \
    --template-body file://`pwd`/hygieia.cf.json \
    --parameters    file://`pwd`/hygieia.parameters.cf.json

Once the resources are build I get the public IP as next:

    aws cloudformation describe-stack-resources --stack-name hygieia-box
    aws ec2 describe-instances --instance-ids i-0197fa8b04a6b5818 --query 'Reservations[*].Instances[*].PublicIpAddress'

At this point I'm ready to access host and confirm software provisioning and check running services states.

    ssh -i ~/.ssh/webadmin.pem ubuntu@52.10.43.90

.





