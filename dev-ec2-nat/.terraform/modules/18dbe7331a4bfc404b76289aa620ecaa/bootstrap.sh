#!/bin/bash

apt-get update -y
apt-get upgrade -y
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py

pip install awscli

apt-get install git -y

mkdir /opt/invoke

aws s3 cp s3://weiblen-invoke-terraform/ssh_key /opt/invoke/ssh_key

GIT_SSH_COMMAND='ssh -i /opt/invoke/ssh_key' git clone git@github.com:cweiblen/bootstrap.git /opt/invoke/bootstrap
