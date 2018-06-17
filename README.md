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

Build 4 cloud boxes to orchestrate the code push cycle.

* jenkins-1
* docker-registry-1
* docker-web-1
* docker-web-2

### Pre-requirements

In order to build EC2 instances we need next AWS things(update jpeerz/hyci/aws/hygieia_parameters.cf.json):

* aws command line tool
* aws ssh key pair
* aws subnet id
* aws vpc id

> this setup is required on jenkins box later

### Getting familiar with Hygieia architecture

Before any continuous implementation is set, a clear understanding of all its pieces is needed. Next we're going to install a fully working instance step by step.

A base linux distro with puppet ready is provisioned with a bootstrap script

    curl -s -o /opt/hygieia.sh https://raw.githubusercontent.com/jpeerz/hyci/master/jenkins/hygieia_boot.sh && bash /opt/hygieia.sh

> previous curl is already triggered by CloudFormation during build.

### Building API+UI project with AWS ec2

A base ubuntu 16 image as IaC with CloudFormation + all dependencies stack provisioned with puppet.

    git clone https://github.com/jpeerz/hyci.git
    cd aws
    bash ./init_cli.sh && source pylibs/bin/activate
    aws cloudformation create-stack  --stack-name hygieia-box-tut1 \
    --template-body file://`pwd`/hygieia_web.cf.json \
    --parameters    file://`pwd`/hygieia_parameters.cf.json

Once the resources are built I get the public IP as next:

    aws cloudformation describe-stack-resources --stack-name hygieia-box-tut1
    aws ec2 describe-instances --query 'Reservations[*].Instances[*].PublicIpAddress' --instance-ids INSTANCE_ID

At this point we're ready to access host and confirm software provisioning and check running services states.

    ssh -i ~/.ssh/webadmin.pem ubuntu@34.220.101.48
    cd ~/hyci/
    sh jenkins/hygieia_setup_and_run.sh /home/ubuntu/hygieia Hygieia-2.0.4

or run as root

    sudo -H -u ubuntu bash -c "sh $HYCI/jenkins/hygieia_setup_and_run.sh $BUILD_WS"











