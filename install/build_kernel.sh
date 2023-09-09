#!/bin/bash
# set -e

# sudo apt install sshpass

# sudo service smbd start
# /home/user/Desktop/devel -nographic &
# devel_pid=$!

# # wait for devel sshd 
# sleep 15

# # a mess
# ( sleep 2; echo ece391 ) | sshpass -pece391 ssh 391devel -o StrictHostKeyChecking=no -T "sed -i 's/SHAREUSER=.*/SHAREUSER=user/' ~/.bashrc; (sleep 2; echo ece391) | source ~/.bashrc; cd ~/build; ls && ls /workdir; make && make install; sleep 15"

# kill $devel_pid
# sudo service smbd stop

# this corrupts the build, dunno why
# have to build kernel manually