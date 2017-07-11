#!/bin/bash -e

echo "================= Installing Riak 2.2.3  ==================="

# Install dependencies
sudo apt-get install -y \
  build-essential \
  libc6-dev-i386 \
  libncurses5-dev \
  openssl \
  libssl-dev \
  fop \
  xsltproc \
  unixodbc-dev \
  libqt4-opengl-dev \
  libpam-dev \
  logrotate



curl -s https://packagecloud.io/install/repositories/basho/riak/script.deb.sh | sudo bash
sudo apt-get install riak=2.2.3-1
