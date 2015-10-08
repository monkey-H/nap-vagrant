#!/bin/bash
set -x

[ -d /opt ] || (sudo mkdir /opt)
sudo cp /home/core/share/flanneld /opt
sudo cp /home/core/share/docker.service /etc/systemd/system
sudo cp /home/core/share/flannel.service /etc/systemd/system

cd /etc/systemd/system

etcdctl mk /coreos.com/network/config '{"Network":"10.0.0.0/16"}'

sudo systemctl enable flannel.service
sudo systemctl start flannel.service

source /run/flannel/subnet.env
sudo systemctl stop docker.service
sudo ifconfig docker0 ${FLANNEL_SUBNET}
sudo systemctl start docker.service
