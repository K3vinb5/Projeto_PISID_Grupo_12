#!/bin/bash

cd ../MongoToSQL/

mvn compile

cp -r target/classes/insertSQL ../Scripts/.

cd ../Scripts/

java -cp "./org.eclipse.paho.client.mqttv3-1.1.0.jar:./mongo-java-driver-3.12.14.jar:./bson-4.11.0.jar:./mongodb-driver-sync-4.0.0.jar:./mariadb-java-client-3.3.3.jar:./mysql-connector-j-8.3.0.jar:./gson-2.10.1.jar:." mainLauncher.FatherMain ./conf/ReceiveCloud.ini insertSQL.ReceiveCloud
