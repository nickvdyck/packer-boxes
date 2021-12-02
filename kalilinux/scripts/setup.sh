#!/bin/bash -eux

# Add vagrant user to sudoers.
echo "vagrant        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

# see Vagrant documentation (https://docs.vagrantup.com/v2/boxes/base.html)
# for details about the requiretty.
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

# Update Box
apt update -y

# Install guest additions
apt install -y qemu-guest-agent
apt install -y spice-vdagent

# Ensure NFS utilities are installed
apt install -y nfs-common
apt install -y nfs-kernel-server

# Install Tools
apt install -y curl
apt install -y wget
apt install -y git
apt install -y vim
