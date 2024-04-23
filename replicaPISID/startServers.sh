#!/bin/bash

# Start MongoDB instances
mongod --config ../replicaPISID/linux/server1/mongod.conf &
mongod --config ../replicaPISID/linux/server2/mongod.conf &
mongod --config ../replicaPISID/linux/server3/mongod.conf &
