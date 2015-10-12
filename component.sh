#!/bin/bash
set -x


docker pull docker.iwanna.xyz:5000/hmonkey/controller:v3
docker pull docker.iwanna.xyz:5000/hmonkey/logger:v1
docker pull docker.iwanna.xyz:5000/hmonkey/database:v1
docker pull docker.iwanna.xyz:5000/hmonkey/moosefs_client:v1
docker pull docker.iwanna.xyz:5000/hmonkey/moosefs_chunkserver:v1
docker pull docker.iwanna.xyz:5000/hmonkey/moosefs_master:v1
docker pull docker.iwanna.xyz:5000/hmonkey/moosefs_metalogger:v1

docker stop database
docker rm database
database_id=$(docker run -d --name database docker.iwanna.xyz:5000/hmonkey/database:v1 /usr/sbin/sshd -D)
database_ip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $database_id)

docker stop logger
docker rm logger
logger_id=$(docker run -d --name database docker.iwanna.xyz:5000/hmonkey/logger:v1 /usr/sbin/sshd -D)
logger_ip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $logger_id)

docker stop mfsmaster
docker rm mfsmaster
mfsmaster_id=$(docker run -d --name mfsmaster docker.iwanna.xyz:5000/hmonkey/moosefs_master:v1 /usr/sbin/sshd -D)
mfsmaster_ip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $mfsmaster_id)

docker stop chunkserver
docker rm chunkserver
sudo rm -r /var/data
sudo mkdir /var/data
chunkserver_id=$(docker run -d -v /var/data:/moosefs --name chunkserver docker.iwanna.xyz:5000/hmonkey/moosefs_chunkserver:v1 /usr/sbin/sshd -D)
chunkserver_ip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $chunkserver_id)

docker stop controller
docker rm controller
controller_id=$(docker run -d --name controller docker.iwanna.xyz:5000/hmonkey/controller:v3 /usr/sbin/sshd -D)
controller_ip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $controller_id)

ssh root@${mfsmaster_ip} "echo '${mfsmaster_ip}	mfsmaster' >> /etc/hosts"
ssh root@${mfsmaster_ip} "/etc/init.d/moosefs-master start"
ssh root@${chunkserver_ip} "echo '${mfsmaster_ip}	mfsmaster' >> /etc/hosts"
ssh root@${chunkserver_ip} "chown -R mfs:mfs /moosefs"
ssh root@${chunkserver_ip} "/etc/init.d/moosefs-chunkserver start"

ssh root@${database_ip} "/etc/init.d/mysql start"
ssh root@${logger_ip} "/etc/init.d/rsyslog start"

ssh root@${controller_ip} "echo '${logger_ip}	logger' >> /etc/hosts"
ssh root@${controller_ip} "/etc/init.d/rsyslog start"
ssh root@${controller_ip} sed -i "s/MFS_MASTER=.*/MFS_MASTER=${mfsmaster_ip}/g" /root/nap/environment_parameters
ssh root@${controller_ip} sed -i "s/MYSQL_IP=.*/MYSQL_IP=${database_ip}/g" /root/nap/environment_parameters
ssh root@${controller_ip} "echo \"command=\\\"/root/nap/nap \\\$SSH_ORIGINAL_COMMAND\\\" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCXIqMeN3fs2ZUwtnsQr6tDbsYHYDBQBUKdi+SL+i7AlqEPgafoBFofeANfgzbwuJXg3cZx+Iy9TVolEC1SCTfKBEfd+zEf4QRDpjSelxRrj5DP7mzteWMrkAl3jZp2JmcSEbZiZel969IQZVZDlvW+J/Py3EKQjxVCvb+R0jHuTRCJurMAiOyn3lUBplO9Vomxhb2+IIJ/AgKqUXmz9m4jciYET7WFqvnkxr6T2p27Ca2eb5rAoqj/yClYOX8bZv11crwp0WqDn+0QreD/G1FDNlmKc4MJSekW6uiisqbF2LZUKC7D3FIh+5ztL96Qou/VUb9nddY0cx3wntNxkXfX coreos\" >> /root/.ssh/authorized_keys"
echo "ssh root@${contoller_ip} " >> /home/core/share/auto/nap
docker build -t web_manager /home/core/share/auto
docker run -d --name web_manager web_manager
