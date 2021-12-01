#!/bin/bash -eux

apt update -y
apt install -y qemu-guest-agent
apt install -y spice-vdagent
apt install -y curl
apt install -y wget
apt install -y git
apt install -y vim
