#!/bin/bash -e
# Begin service ENV variables
export SHIPPABLE_ES_CLUSTER_NAME=shippabletest;
export SHIPPABLE_ES_PORT=9200;
export SHIPPABLE_ES_BINARY="/usr/local/bin/elasticsearch";
#export SHIPPABLE_ES_USER=elasticsearch
export SHIPPABLE_ES_TMP=/usr/local/elasticsearch/tmp
export SHIPPABLE_ES_CMD="$SHIPPABLE_ES_BINARY -Ecluster.name=$SHIPPABLE_ES_CLUSTER_NAME";
# End service ENV variables

#
# Function to START
#
start_service() {
  start_generic_service "elasticsearch" "$SHIPPABLE_ES_BINARY" "$SHIPPABLE_ES_CMD" "$SHIPPABLE_ES_PORT";
}

# Function to stop
stop_service() {
  kill -9 `ps aux | grep elasticsearch | awk '{print $2}'`
}

source /u16all/test/function_start_generic.sh
#
# Call to start service
#
echo "================= Starting elasticsearch ==================="
printf "\n"
start_service
printf "\n\n"
echo "================= Stopping elasticsearch ==================="
printf "\n"
stop_service
printf "\n\n"
