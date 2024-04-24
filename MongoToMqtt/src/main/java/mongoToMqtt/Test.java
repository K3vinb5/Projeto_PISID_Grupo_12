package mongoToMqtt;

import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;
import org.eclipse.paho.client.mqttv3.MqttCallback;
import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.MqttMessage;

public class Test {

    public static void main(String[] args) {
        String broker = "tcp://broker.emqx.io:1883";
        String clientId = "demo_client";
        String topic = "topic/test";
        int subQos = 1;
        int pubQos = 1;
        String msg = "Hello MQTT";

        try {
            MqttClient client = new MqttClient(broker, clientId);
            MqttConnectOptions options = new MqttConnectOptions();
            client.connect(options);

            if (client.isConnected()) {
                client.setCallback(new MqttCallback() {
                    public void messageArrived(String topic, MqttMessage message) throws Exception {
                        System.out.println("topic: " + topic);
                        System.out.println("qos: " + message.getQos());
                        System.out.println("message content: " + new String(message.getPayload()));
                    }

                    public void connectionLost(Throwable cause) {
                        System.out.println("connectionLost: " + cause.getMessage());
                    }

                    public void deliveryComplete(IMqttDeliveryToken token) {
                        System.out.println("deliveryComplete: " + token.isComplete());
                    }
                });

                client.subscribe(topic, subQos);

                MqttMessage message = new MqttMessage(msg.getBytes());
                message.setQos(pubQos);
                client.publish(topic, message);
            }

            client.disconnect();
            client.close();

        } catch (MqttException e) {
            e.printStackTrace();
        }
    }
}
