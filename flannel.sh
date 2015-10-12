#!/bin/bash

cp ./id_dsa /home/core/.ssh
cp ./id_dsa.pub /home/core/.ssh

[ -d /opt ] || (sudo mkdir /opt)
sudo cp /home/core/share/flanneld /opt
sudo cp /home/core/share/docker.service /etc/systemd/system
sudo cp /home/core/share/flannel.service /etc/systemd/system

cd /etc/systemd/system

for i in 1 2 3 4; do

	[ -z $(etcdctl get /coreos.com/network/config 2>/dev/null) ] && (etcdctl mk /coreos.com/network/config '{"Network":"10.0.0.0/16"}')

	sudo systemctl enable flannel.service
	sudo systemctl start flannel.service
	if [ -f /run/flannel/subnet.env ]; then
		break
	fi

	if [ 4 -eq $i ]; then
		echo "failed and try again"
		exit
	fi

done

source /run/flannel/subnet.env

sudo systemctl stop docker.service
sudo ifconfig docker0 ${FLANNEL_SUBNET}
sudo systemctl start docker.service
