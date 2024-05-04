#!/bin/bash

cd ../MongoToSQL/

mvn compile

cp -r target/classes/insertSQL ../Scripts/.

cd ../Scripts/

java -cp "./lib/org.eclipse.paho.client.mqttv3-1.1.0.jar:./lib/mongo-java-driver-3.12.14.jar:./lib/bson-4.11.0.jar:./lib/mongodb-driver-sync-4.0.0.jar:./lib/mariadb-java-client-3.3.3.jar:./lib/mysql-connector-j-8.3.0.jar:./lib/gson-2.10.1.jar:./lib/mongodb-driver-core-4.0.0.jar:." mainLauncher.FatherMain ./conf/ReceiveCloud.ini insertSQL.ReceiveCloud
