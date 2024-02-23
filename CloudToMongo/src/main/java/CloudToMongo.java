import com.google.gson.Gson;
import com.google.gson.JsonObject;
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
import java.util.List;

/**
 * @author Kevin
 * @version 1.0
 */
public class CloudToMongo implements MqttCallback {
    static MongoClient mongoClient;
    static DB db;
    static String mongo_user = "";
    static String mongo_password = "";
    static String mongo_address = "";
    static String cloud_server = "";
    static String mongo_host = "";
    static String mongo_replica = "";
    static String mongo_database = "";
    static String mongo_authentication = "";
    static List<String> cloud_topics = new ArrayList<>();
    static List<String> mongo_collections = new ArrayList<>();
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
            mongo_host = p.getProperty("mongo_host");
            mongo_database = p.getProperty("mongo_database");
            mongo_authentication = p.getProperty("mongo_authentication");
            cloud_topics = Arrays.stream(p.getProperty("cloud_topics").split(",")).toList();
            mongo_collections = Arrays.stream(p.getProperty("mongo_collections").split(",")).toList();
        } catch (Exception e) {
            System.out.println("Error reading CloudToMongo.ini file " + e);
            JOptionPane.showMessageDialog(null, "The CloudToMongo.ini file wasn't found.", "CloudToMongo", JOptionPane.ERROR_MESSAGE);
            System.exit(1);
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
            mqttclient = new MqttClient(cloud_server, "CloudToMongo_" + String.valueOf(i) + "_" + "pisid_grupo12");
            mqttclient.connect();
            mqttclient.setCallback(this);
            for (String cloud_topic : cloud_topics) {
                mqttclient.subscribe(cloud_topic);
            }
        } catch (MqttException e) {
            e.printStackTrace();
        }
    }

    /**
     * Connects to Mongo DataBase specified in .ini file
     */
    public void connectMongo() {
        //TODO fix this code so it uses the variables provided by the .ini file
        String mongoURI = /*"mongodb://*/"";

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

        mongoClient = new MongoClient(new MongoClientURI(mongoURI));
        db = mongoClient.getDB(mongo_database);
        //mongocol = db.getCollection(mongo_collection);
    }

    /**
     *
     * @param topic The topic that we have received
     * @param c MqttMessage, it is already in a json format that is why we create a document to using Json.parse
     * @throws Exception
     */
    @Override
    public void messageArrived(String topic, MqttMessage c) throws Exception {

        try {
            DBCollection mongocol;
            JsonObject jsonObject = new Gson().fromJson(c.toString(), JsonObject.class);
            DBObject document_json;
            document_json = (DBObject) JSON.parse(c.toString());
            switch (topic){
                case "pisid_grupo12_temp":
                    if (jsonObject.get("Sensor").getAsInt() == 1){
                        mongocol = db.getCollection(mongo_collections.get(0));
                        mongocol.insert(document_json);
                    }else if((jsonObject.get("Sensor").getAsInt() == 2)){
                        mongocol = db.getCollection(mongo_collections.get(1));
                        mongocol.insert(document_json);
                    }
                    break;
                case "pisid_grupo12_maze":
                    mongocol = db.getCollection(mongo_collections.getLast());
                    mongocol.insert(document_json);
                    break;
                default:
            }
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