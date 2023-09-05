#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

apt update && apt install openssh-server sudo vim x11-apps samba git curl perl libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev libsdl1.2-dev libgtk2.0-dev python2 -y
apt-get clean -y

echo "Port $SSH_PORT" >> /etc/ssh/sshd_config
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
echo "X11Forwarding yes" >> /etc/ssh/sshd_config
echo 