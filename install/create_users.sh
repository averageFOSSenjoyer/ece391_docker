#!/usr/bin/env bash
### every exit != 0 fails the script
set -e

echo "changing root user password"
echo "root:root" | chpasswd

echo "creating user user"
useradd -rm -d /home/user -s /bin/bash -g root -G sudo -u 1001 user
echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
echo "user:ece391" | chpasswd