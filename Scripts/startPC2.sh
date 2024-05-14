if [ "$EUID" -ne 0 ]; then
    echo "Run this with sudo"
    exit 1
fi


./MqttToSQL.sh

