#!/bin/bash

BUILD_WS=/home/ubuntu
HYCI=${BUILD_WS}/hyci
PUPPETPARTS=${BUILD_WS}/puppetparts
HYGIEIA=${BUILD_WS}/hygieia

modules=( $2 )
for PUPPET_MOD in ${modules[@]};do
    echo "building $PUPPET_MOD"
    #puppet apply --environment localhost --modulepath ${BUILD_WS}/puppetparts/puppet/modules:/etc/puppet/modules ${BUILD_WS}/puppetparts/puppet/modules/core/manifests/${PUPPET_MOD}.pp
done

echo 'Configuration Completed.'
