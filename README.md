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

### Additional tools

Reusing code from my toolbox:

* https://github.com/jpeerz/puppetparts.git
* https://github.com/jpeerz/hyci.git
* https://github.com/jpeerz-hygieia/Hygieia.git

### Getting familiar with Hygieia architecture

Before any continuous implementation is set, a clear understanding of all its pieces is needed. Next we're going to install a fully working instance step by step.

A base linux distro with puppet ready is provisioned with a bootstrap script

    curl -s -o /opt/hygieia.sh https://raw.githubusercontent.com/jpeerz/hyci/master/jenkins/hygieia_boot.sh && bash /opt/hygieia.sh

> previous curl is already triggered by CloudFormation during build.

### Building API+UI project with AWS ec2 (docker-web-test-2.hyci)

A base ubuntu 16 image as IaC with CloudFormation + all dependencies stack provisioned with puppet.

    git clone https://github.com/jpeerz/hyci.git
    cd aws
    bash ./init_cli.sh && source pylibs/bin/activate
    export EC2_INSTANCE_NAME=hygieia-box-manual-1
    aws cloudformation create-stack  --stack-name $EC2_INSTANCE_NAME \
    --template-body file://`pwd`/hygieia_web.cf.json \
    --parameters    file://`pwd`/hygieia_parameters.cf.json

This CF will provision the new machine with next stack

    * java
    * maven
    * mongodb
    * nodejs

Once the resources are built I get the public IP as next:

    ec2_instance_id = $(aws cloudformation describe-stack-resources --output text --stack-name $EC2_INSTANCE_NAME | grep 'AWS::EC2::Instance' | awk '{print $3}')
    aws ec2 describe-instances --query 'Reservations[*].Instances[*].PublicIpAddress' --output text --instance-ids $ec2_instance_id

At this point we're ready to access host and confirm software provisioning and check running services states.

    ssh -i ~/.ssh/webadmin.pem ubuntu@54.191.95.91
    tail -f /var/log/syslog

e.g. Setup Hygieia api and ui then start as spring boot processes
    
    cd ~/hyci/
    sh /home/ubuntu/hygieia/jenkins/hygieia_setup_and_run.sh /home/ubuntu/hygieia Hygieia-2.0.4

or run as root

    export HYCI=/home/ubuntu/hygieia
    sudo -H -u ubuntu bash -c "sh $HYCI/jenkins/hygieia_setup_and_run.sh $HOME/hygieia Hygieia-2.0.4"

After some minutes build process the UI must be available at 

http://54.191.95.91:3000

## Time to orchestrate

### Build jenkins-1 machine

    aws cloudformation create-stack --stack-name ci-1 \
    --template-body file://`pwd`/puppetparts/aws/hygieia_jenkins.cf.json \
    --parameters    file://`pwd`/puppetparts/aws/hygieia_parameters.cf.json

This CF will provision the new machine with next stack

    * awscli
    * java
    * maven
    * jenkins

We're ready to complete Jenkins initial setup

    ssh -i ~/.ssh/webadmin.pem ubuntu@54.202.195.169
    # cat thepasswordfile

> install this *.pem key for the jenkins user

Browse to new Jenkins url http://54.202.195.169:8080 to install recommended plugins, then go to [Global Tool Config](http://54.202.195.169:8080/configureTools/) and set

java

    JDK
    ORACLE8
    /usr/lib/jvm/java-8-oracle/

mvn

    MAVEN
    MAVEN3
    /usr/share/maven/

github [GitHubPushTrigger](https://wiki.jenkins.io/display/JENKINS/Github+Plugin)

> confirm webhook is properly added at your repo https://github.com/jpeerz-hygieia/Hygieia/settings/hooks

If we need to remove token go to https://github.com/settings/developers

### Build docker-registry-1 machine

Let's build a docker registry instace to store all releases as containers.

    aws cloudformation create-stack --stack-name docker-registry-1 \
    --template-body file://`pwd`/puppetparts/aws/hygieia_docker_registry.cf.json \
    --parameters    file://`pwd`/puppetparts/aws/hygieia_parameters.cf.json

Use a docker volume to persist containers catalog

    docker volume create dockreg
    docker run -d -p 5000:5000 --restart=always --name registry -v dockreg:/var/lib/registry registry:2

We can use the resgistry REST endpoint to list available containers.

    curl http://34.215.221.237:5000/v2/_catalog
    {"repositories":["hygieia-api","hygieia-ui"]}

Create docker cluster

    docker run -d --restart=unless-stopped --name rancher -p 8080:80 -p 8443:443 rancher/rancher
    https://34.215.221.237:8443/    admin/admin

When we need to include new container, do as next:

    docker tag hygieia-ui localhost:5000/hygieia-api
    docker push localhost:5000/hygieia-api
    docker tag hygieia-ui localhost:5000/hygieia-ui
    docker push localhost:5000/hygieia-ui

### Build docker-web machine (docker-web-test-3.hyci)

This web box is a docker slave ready to pull containers and run apps.

Run first time

    docker volume create hygieia_logs
    docker volume create hygieia_data
    docker run -d -p 27017:27017 --name mongodb -v hygieia_data:/data/db mongo:latest  mongod --smallfiles
    docker exec -t -i mongodb mongo admin --eval 'db.getSiblingDB("dashboarddb").createUser({user: "dashboarduser", pwd: "admin", roles: [{role: "readWrite", db: "dashboarddb"}]})'

#### Next is done by hygieia-build jenkins pipeline

    export DOCKER_REG=34.215.221.237

Download containers

    docker pull $DOCKER_REG:5000/hygieia-ui
    docker pull $DOCKER_REG:5000/hygieia-api

Start database

    docker run -d -p 27017:27017 --name mongodb -v hygieia_data:/data/db mongo:latest  mongod --smallfiles

Init API service with minimal ENV values

    docker run \
    --name api \
    --link mongodb:mongo \
    -e SPRING_DATA_MONGODB_DATABASE=dashboarddb \
    -e SPRING_DATA_MONGODB_HOST=127.0.0.1 \
    -e SPRING_DATA_MONGODB_USERNAME=dashboarduser \
    -e SPRING_DATA_MONGODB_PASSWORD=admin \
    -p 8080:8080 \
    -v hygieia_logs:/hygieia/logs \
    -dti $DOCKER_REG:5000/hygieia-api:Hygieia-2.0.4

Start up the UI

    docker run \
    --name ui \
    --link api \
    -p 8088:80 \
    -e HYGIEIA_API_PORT=http://api:8080 \
    -dti $DOCKER_REG:5000/hygieia-ui:Hygieia-2.0.4

start one collector (github)

    docker run \
    --name github-scm \
    --link mongodb:mongo-db \
    -e MONGO_PORT=tcp://mongo-db:27017 \
    -e HYGIEIA_API_ENV_SPRING_DATA_MONGODB_DATABASE=dashboarddb \
    -e HYGIEIA_API_ENV_SPRING_DATA_MONGODB_USERNAME=dashboarduser \
    -e HYGIEIA_API_ENV_SPRING_DATA_MONGODB_PASSWORD=admin \
    -itd $DOCKER_REG:5000/hygieia-github-scm-collector:Hygieia-2.0.4

Ready to browse dashboard at 18.236.159.168:8888

## All running

|local host name         |      address                          |
|------------------------|---------------------------------------|
|ci-six.hyci             | http://54.202.195.169:8080/           |
|docke-one.hyci          | http://34.215.221.237:5000/v2/_catalog|
|docker-web-test-2.hyci  | http://54.191.95.91:3000              |
|docker-web-test-2.hyci  | http://18.236.159.168:8888            |

## TODO

* Deploy & Configure controllers containers on pull machines (docker-web's CF template)
* Update daemon.json to use private IP only
* Automate password generation
* Don't stop pipeline on `docker stop`
* Script pipeline to add new ec2 machines as node using jenkins REST API.

