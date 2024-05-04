#!/bin/bash

cd ../MongoToMqtt

mvn compile

cp -r target/classes/mongoToMqtt ../Scripts/.

cd ../Scripts/

java -cp "./lib/org.eclipse.paho.client.mqttv3-1.1.0.jar:./lib/mongo-java-driver-3.12.14.jar:./lib/bson-4.11.0.jar:./lib/mongodb-driver-sync-4.0.0.jar:." mainLauncher.FatherMain ./conf/SendCloud.ini mongoToMqtt.MongoToMqttWorker
