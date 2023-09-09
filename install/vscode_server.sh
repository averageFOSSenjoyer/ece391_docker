#!/bin/bash
set -e

VERSION=4.16.1

if [[ $(uname -m) == "x86_64" ]]
then
    ARCH="amd64"
else
    ARCH="arm64"
fi

curl -fOL https://github.com/coder/code-server/releases/download/v$VERSION/code-server_${VERSION}_${ARCH}.deb
sudo dpkg -i code-server_${VERSION}_${ARCH}.deb

mkdir -p ~/.config/code-server/

echo "
bind-addr: 0.0.0.0:8080
auth: password
password: ece391
cert: false
" > ~/.config/code-server/config.yaml