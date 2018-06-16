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

Build 4 cloud boxes to orchestrate the code push cycle

* jenkins-1
* docker-registry-1
* docker-web-1
* docker-web-2

## building api+ui project with aws ec2 (manual process)



## deploy CI machine



### add aws cli capabilities



## deploy WEB node controlled by CI



## deploy DOCKER node controlled by CI



[docker build](https://github.com/capitalone/Hygieia/blob/gh-pages/pages/hygieia/Build/builddocker.md)



### storing images in local registry



## deploy QA node after build completed successfully




