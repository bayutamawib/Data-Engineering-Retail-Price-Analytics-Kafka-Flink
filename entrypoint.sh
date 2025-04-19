#!/bin/bash
set -e

echo "Starting Flink with args: $@"

# Wait for Kafka to be available (optional)
# ./bin/wait-for-it.sh kafka-1:9092 -t 30

# Start Flink JobManager or TaskManager
if [ "$1" == "jobmanager" ]; then
  /opt/flink/bin/jobmanager.sh start
  tail -f /dev/null

elif [ "$1" == "taskmanager" ]; then
  # Optional: Wait for JobManager
  while ! nc -z flink-jobmanager 6123; do
    sleep 1
  done
  exec /opt/flink/bin/taskmanager.sh start-foreground

else
  exec "$@"
fi
