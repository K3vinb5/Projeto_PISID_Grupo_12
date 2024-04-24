#!/bin/bash

# Get process IDs of MongoDB instances
mongo_pids=$(pgrep mongod)

# Check if MongoDB instances are running
if [ -z "$mongo_pids" ]; then
    echo "No MongoDB instances are currently running."
else
    # Stop each MongoDB instance
    for pid in $mongo_pids; do
        echo "Stopping MongoDB instance with PID: $pid"
        kill "$pid"
    done
    echo "MongoDB instances stopped."
fi
