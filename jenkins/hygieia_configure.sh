#!/bin/bash

BUILD_WS=/home/ubuntu
HYCI=${BUILD_WS}/hyci
PUPPETPARTS=${BUILD_WS}/puppetparts
HYGIEIA=${BUILD_WS}/hygieia

chown -R ubuntu:ubuntu $BUILD_WS && sudo -H -u ubuntu bash -c "sh $HYCI/jenkins/hygieia_setup_and_run.sh $BUILD_WS"

echo 'Configuration Completed.'
