#!/bin/bash -e

SQLITE_VERSION=3.22.0
echo "================= Installing SQLite $SQLITE_VERSION ==================="

sudo add-apt-repository ppa:jonathonf/backports
sudo apt-get update && sudo apt-get install sqlite3="$SQLITE_VERSION"*

pushd /tmp
  wget https://www.sqlite.org/2017/sqlite-tools-linux-x86-3220000.zip
  unzip -u sqlite-tools-linux-x86-3220000.zip
  cp -r sqlite-tools-linux-x86-3220000/. /usr/bin
  rm -rf sqlite-tools-linux-x86-3220000*
popd
