@echo off
start "Server db1" /MIN mongod --config /replicaPISID/server1/mongod.conf
start "Server db2" /MIN mongod --config /replicaPISID/server2/mongod.conf
start "Server db3" /MIN mongod --config /replicaPISID/server3/mongod.conf