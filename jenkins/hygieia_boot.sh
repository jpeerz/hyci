#!/bin/bash

BUILD_WS=/home/ubuntu
HYCI=${BUILD_WS}/hyci
PUPPETPARTS=${BUILD_WS}/puppetparts
HYGIEIA=${BUILD_WS}/hygieia

# add swap space
fallocate -l 4G /mnt/4GB.swap && dd if=/dev/zero of=/mnt/4GB.swap bs=1024 count=4194304
chmod 0600 /mnt/4GB.swap  && mkswap /mnt/4GB.swap && swapon /mnt/4GB.swap
echo '/mnt/4GB.swap none  swap  sw 0  0' >> /etc/fstab

# include github provision scripts
git clone https://github.com/jpeerz/puppetparts.git ${PUPPETPARTS}
git clone https://github.com/jpeerz/hyci.git $HYCI
git clone https://github.com/jpeerz/Hygieia.git $HYGIEIA

cp ${PUPPETPARTS}/puppet/modules/core/files/puppet.conf /etc/puppet/puppet.conf

echo 'Ready for provisioning.'
