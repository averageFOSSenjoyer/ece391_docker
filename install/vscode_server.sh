#!/bin/bash
set -e

VERSION=4.16.1

curl -fOL https://github.com/coder/code-server/releases/download/v$VERSION/code-server_${VERSION}_amd64.deb
sudo dpkg -i code-server_${VERSION}_amd64.deb

mkdir -p ~/.config/code-server/

echo "
bind-addr: 0.0.0.0:8080
auth: password
password: ece391
cert: false
" > ~/.config/code-server/config.yaml