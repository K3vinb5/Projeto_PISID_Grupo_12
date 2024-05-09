#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Run this with sudo"
    exit 1
fi

find . -type d -name '*tcpbroker*' -exec rm -r {} +

./compileMainLauncher.sh

./MqttToMongo.sh

./MongoToMqtt.sh

./MqttToSQL.sh
