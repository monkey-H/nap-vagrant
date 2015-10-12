#!/bin/bash
set -x 

vagrant ssh core-01 -c "cd /home/core/share && sh flannel.sh"
echo "core-01 flannel success"
vagrant ssh core-02 -c "cd /home/core/share && sh flannel.sh"
echo "core-02 flannel success"
vagrant ssh core-03 -c "cd /home/core/share && sh flannel.sh"
echo "core-03 flannel success"
vagrant ssh core-01 -c "cd /home/core/share && sh component.sh"
echo "nap component install success"
