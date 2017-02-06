#!/bin/bash -e

sudo chmod 1777 /tmp

#install vim for easy debugging
apt-get update && apt-get install vim

for file in /u16all/version/*.sh;
do
  . $file
done

mkdir -p /var/lib/neo4j/conf
cd /u16all && cp -rf neo4j-server.properties /var/lib/neo4j/conf/

echo "================= Adding mysql cnf ==================="
cd /u16all && cp -rf my.cnf /etc/mysql/my.cnf

echo "================= Adding PostgreSQL cnf ==================="
cd /u16all && cp -rf pg_hba.cnf /etc/postgresql/9.6/main/pg_hba.conf

echo "================= Cleaning package lists ==================="
apt-get clean
apt-get autoclean
apt-get autoremove
