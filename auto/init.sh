#!/bin/bash

eval 'ssh-agent'
ssh-add
/etc/init.d/ganglia-monitor restart
/etc/init.d/gmetad restart
python /opt/nap/manage.py runserver 0.0.0.0:80
