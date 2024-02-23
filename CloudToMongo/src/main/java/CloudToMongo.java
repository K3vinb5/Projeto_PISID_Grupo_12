import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;
import org.eclipse.paho.client.mqttv3.MqttCallback;
import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.MqttMessage;

import com.mongodb.*;
import com.mongodb.util.JSON;

import javax.swing.*;
import java.util.*;

import java.io.*;
import java.awt.*;
import java.awt.event.*;

/**
 * @author Kevin
 * @version 1.0
 */
public class CloudToMongo implements MqttCallback {
    static MongoClient mongoClient;
    static DB db;
    static DBCollection mongocol;
    static String mongo_user = "";
    static String mongo_password = "";
    static String mongo_address = "";
    static String cloud_server = "";
    static String cloud_topic = "";
    static String mongo_host = "";
    static String mongo_replica = "";
    static String mongo_database = "";
    static String mongo_collection = "";
    static String mongo_authentication = "";
    static JTextArea documentLabel = new JTextArea("\n");
    MqttClient mqttclient;

    /**
     * Creates a basic GUI
     */
    private static void createWindow() {
        JFrame frame = new JFrame("Cloud to Mongo");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        JLabel textLabel = new JLabel("Data from broker: ", SwingConstants.CENTER);
        textLabel.setPreferredSize(new Dimension(600, 30));
        JScrollPane scroll = new JScrollPane(documentLabel, JScrollPane.VERTICAL_SCROLLBAR_ALWAYS, JScrollPane.HORIZONTAL_SCROLLBAR_ALWAYS);
        scroll.setPreferredSize(new Dimension(600, 200));
        JButton b1 = new JButton("Stop the program");
        frame.getContentPane().add(textLabel, BorderLayout.PAGE_START);
        frame.getContentPane().add(scroll, BorderLayout.CENTER);
        frame.getContentPane().add(b1, BorderLayout.PAGE_END);
        frame.setLocationRelativeTo(null);
        frame.pack();
        frame.setVisible(true);
        b1.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent evt) {
                System.exit(0);
            }
        });
    }

    public static void main(String[] args) {
        createWindow();
        try {
            Properties p = new Properties();
            p.load(new FileInputStream("CloudToMongo.ini"));
            mongo_address = p.getProperty("mongo_address");
            mongo_user = p.getProperty("mongo_user");
            mongo_password = p.getProperty("mongo_password");
            mongo_replica = p.getProperty("mongo_replica");
            cloud_server = p.getProperty("cloud_server");
            cloud_topic = p.getProperty("cloud_topic");
            mongo_host = p.getProperty("mongo_host");
            mongo_database = p.getProperty("mongo_database");
            mongo_authentication = p.getProperty("mongo_authentication");
            mongo_collection = p.getProperty("mongo_collection");
        } catch (Exception e) {
            System.out.println("Error reading CloudToMongo.ini file " + e);
            JOptionPane.showMessageDialog(null, "The CloudToMongo.inifile wasn't found.", "CloudToMongo", JOptionPane.ERROR_MESSAGE);
        }
        new CloudToMongo().connecCloud();
        new CloudToMongo().connectMongo();
    }

    /**
     * Connects to Mqtt Broker
     */
    public void connecCloud() {
        int i;
        try {
            i = new Random().nextInt(100000);
            mqttclient = new MqttClient(cloud_server, "CloudToMongo_" + String.valueOf(i) + "_" + cloud_topic);
            mqttclient.connect();
            mqttclient.setCallback(this);
            mqttclient.subscribe(cloud_topic);
        } catch (MqttException e) {
            e.printStackTrace();
        }
    }

    /**
     * Connects to Mongo DataBase specified in .ini file
     */
    public void connectMongo() {
        String mongoURI = /*"mongodb://"*/"";

        /*if (mongo_authentication.equals("true")) {
            mongoURI = mongoURI + mongo_user + ":" + mongo_password + "@";
        }*/

        mongoURI = mongoURI + mongo_address;

        if (!mongo_replica.equals("false")) {
            if (mongo_authentication.equals("true")) {
                mongoURI = mongoURI + "/?replicaSet=" + mongo_replica + "&authSource=admin";
            } else {
                mongoURI = mongoURI + "/?replicaSet=" + mongo_replica;
            }
        } else {
            /*if (mongo_authentication.equals("true")) {
                mongoURI = mongoURI + "/?authSource=admin";
            }*/
        }

        MongoClient mongoClient = new MongoClient(new MongoClientURI("mongodb+srv://admin:admin@pisid-grupo12.as9ayjp.mongodb.net/"));
        db = mongoClient.getDB(mongo_database);
        mongocol = db.getCollection(mongo_collection);
    }

    @Override
    public void messageArrived(String topic, MqttMessage c) throws Exception {
        try {
            DBObject document_json;
            document_json = (DBObject) JSON.parse(c.toString());
            mongocol.insert(document_json);
            documentLabel.append(c.toString() + "\n");
        } catch (Exception e) {
            System.out.println(e);
        }
    }

    @Override
    public void connectionLost(Throwable cause) {
    }


    @Override
    public void deliveryComplete(IMqttDeliveryToken token) {
    }
}