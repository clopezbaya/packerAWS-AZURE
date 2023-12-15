#!/bin/bash

sleep 30

sudo yum update -y

sudo yum install -y gcc-c++ make
curl -sL https://rpm.nodesource.com/setup_14.x | sudo -E bash -
sudo yum install -y nodejs
sudo yum install -y jq
sudo yum install unzip -y
sudo yum install nginx -y
cd ~/ && unzip NodeAPP.zip
cd ~/NodeAPP && npm i

sudo mv /tmp/node.service /etc/systemd/system/node.service
sudo systemctl enable node.service
sudo systemctl start node.service