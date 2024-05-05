#!/bin/bash

cd ../MainLauncher

chmod 755 *

mvn compile

cp -r target/classes/mainLauncher ../Scripts/.
