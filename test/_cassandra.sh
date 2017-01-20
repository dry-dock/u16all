#!/bin/bash -e
# Begin service ENV variables
export SHIPPABLE_CASSANDRA_PORT=9042;
export SHIPPABLE_CASSANDRA_BINARY="/usr/sbin/cassandra";
export SHIPPABLE_CASSANDRA_CMD="$SHIPPABLE_CASSANDRA_BINARY -R";
export SHIPPABLE_CASSANDRA_LOG="/var/log/cassandra/system.log"
# End service ENV variables

#
# Function to START
#
start_service() {
  start_generic_service "Cassandra" "$SHIPPABLE_CASSANDRA_BINARY" "$SHIPPABLE_CASSANDRA_CMD" "$SHIPPABLE_CASSANDRA_PORT"
}

#
# Function to STOP
#
stop_service() {
  sudo kill -9 `ps aux | grep [c]assandra | awk '{print $2}'`
}

source /u16all/test/function_start_generic.sh
#
# Call to start service
#
echo "================= Starting cassandra ==================="
printf "\n"
start_service
printf "\n\n"
echo "================= Stopping cassandra ==================="
printf "\n"
stop_service
printf "\n\n"
