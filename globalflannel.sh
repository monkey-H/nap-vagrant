#!/bin/bash
set -x 

vagrant ssh core-01 -c "cd /home/core/share && sh flannel.sh"
vagrant ssh core-02 -c "cd /home/core/share && sh flannel.sh"
vagrant ssh core-03 -c "cd /home/core/share && sh flannel.sh"
