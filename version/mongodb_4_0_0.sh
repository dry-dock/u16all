#!/bin/bash -e

MONGO_VERSION=4.0.0
echo "================= Installing Mongodb $MONGO_VERSION ==================="

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
echo "deb [ arch=amd64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list

sudo apt-get update
sudo apt-get install -y mongodb-org="$MONGO_VERSION" \
        mongodb-org-server="$MONGO_VERSION" \
        mongodb-org-shell="$MONGO_VERSION" \
        mongodb-org-mongos="$MONGO_VERSION" \
        mongodb-org-tools="$MONGO_VERSION"


# Create the data directory
sudo mkdir -p /data/db

# Pin the current version
sudo echo "mongodb-org hold" | sudo dpkg --set-selections
sudo echo "mongodb-org-server hold" | sudo dpkg --set-selections
sudo echo "mongodb-org-shell hold" | sudo dpkg --set-selections
sudo echo "mongodb-org-mongos hold" | sudo dpkg --set-selections
sudo echo "mongodb-org-tools hold" | sudo dpkg --set-selections
