#!/bin/bash -e

echo "================= Installing redis-server ==================="

# Installs redis-server from chris-lea's PPA
sudo add-apt-repository ppa:chris-lea/redis-server
sudo apt-get update
sudo wget https://redis.io/download
sudo apt-get install redis-server=4:4.0.10*
