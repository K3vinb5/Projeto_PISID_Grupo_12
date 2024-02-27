import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;
import org.eclipse.paho.client.mqttv3.MqttCallback;
import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.MqttMessage;

import java.util.*;

import java.io.*;
import javax.swing.*;
import java.awt.*;
import java.awt.event.*;

/**
 * @author kevin
 * @version 1.0
 */
public class SendCloud  implements MqttCallback  {
    static MqttClient mqttclient;
    static String cloud_server = "";
    static String cloud_topic = "";
    static JTextArea textArea = new JTextArea(10, 50);

    /**
     * Publishes a message to the topic specified in the .ini file
     * @param leitura Message to be sent
     */
    public static void publishSensor(String leitura) {
        try {
            MqttMessage mqtt_message = new MqttMessage();
            mqtt_message.setPayload(leitura.getBytes());
            mqttclient.publish(cloud_topic, mqtt_message);
        } catch (MqttException e) {
            e.printStackTrace();
        }
    }

    /**
     * Method that creates the gui
     */
    private static void createWindow() {
        JFrame frame = new JFrame("Send to Cloud");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        JLabel textLabel = new JLabel("Data to send do broker: ",SwingConstants.CENTER);
        JButton b1 = new JButton("Send Data");
        frame.getContentPane().add(textLabel, BorderLayout.PAGE_START);
        frame.getContentPane().add(textArea, BorderLayout.CENTER);
        frame.getContentPane().add(b1, BorderLayout.PAGE_END);
        frame.setLocationRelativeTo(null);
        frame.pack();
        frame.setVisible(true);
        b1.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
                //System.exit(0);
                publishSensor(textArea.getText());
            }
        });
    }

    public static void main(String[] args) {

        try {
            Properties p = new Properties();
            p.load(new FileInputStream("SendCloud.ini"));
            cloud_server = p.getProperty("cloud_server");
            cloud_topic = p.getProperty("cloud_topic");
        } catch (Exception e) {

            System.out.println("Error reading SendCloud.ini file " + e);
            JOptionPane.showMessageDialog(null, "The SendCloud.ini file wasn't found.", "Send Cloud", JOptionPane.ERROR_MESSAGE);
        }
        new SendCloud().connecCloud();
        createWindow();

    }

    /**
     * Connects mqttClient to Coud specified in the .ini file
     */
    public void connecCloud() {
        try {
            mqttclient = new MqttClient(cloud_server, "SimulateSensor" + cloud_topic);
            mqttclient.connect();
            mqttclient.setCallback(this);
            mqttclient.subscribe(cloud_topic);
        } catch (MqttException e) {
            e.printStackTrace();
        }
    }


    @Override
    public void connectionLost(Throwable cause) {    }
    @Override
    public void deliveryComplete(IMqttDeliveryToken token) { }
    @Override
    public void messageArrived(String topic, MqttMessage message){ }

}