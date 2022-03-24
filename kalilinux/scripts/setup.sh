#!/bin/bash -eux

# Add vagrant user to sudoers.
echo "vagrant        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

# see Vagrant documentation (https://docs.vagrantup.com/v2/boxes/base.html)
# for details about the requiretty.
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
