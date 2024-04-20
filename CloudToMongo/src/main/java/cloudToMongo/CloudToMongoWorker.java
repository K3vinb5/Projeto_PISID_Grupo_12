package cloudToMongo;

import java.util.Arrays;
import java.util.Random;

import javax.swing.*;
import java.awt.*;
import java.awt.event.*;

import org.bson.Document;
import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;
import org.eclipse.paho.client.mqttv3.MqttCallback;
import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.MqttMessage;

import com.mongodb.MongoClient;
import com.mongodb.MongoClientURI;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;

public class CloudToMongoWorker implements MqttCallback {

    static JTextArea documentLabel = new JTextArea("\n");
    static private CollectionPersonalized collectionPersonalized;
    static private MqttClient mqttclient;
    static private String cloud_server;
    static private String cloud_topic;
    static private String mongoURI;
    static private MongoClient mongoClient;
    static private String mongo_database;
    static private MongoDatabase db;
    static private boolean enable_window;

    // Main
    public static void main(String[] args) {
        if (!setAttibutes(args))
            return;

        CloudToMongoWorker mongoSender = new CloudToMongoWorker();
        CloudToMongoWorker mqttReceiver = new CloudToMongoWorker();

        if (enable_window)
            createWindow();
        try {
            mongoSender.connectMongo();

            mongoSender.setAutoIncrement();

            mqttReceiver.connectCloud();

        } catch (Exception e) {
            System.err.println(e.getMessage());
        }
    }

    // Factory
    // [0] - cloud_server,
    // [1] - topic,
    // [2] - mongoURI,
    // [3] - mongo_database,
    // [4] - collection,
    // [5] - enable_window
    private static boolean setAttibutes(String[] args) {
        if (args == null || args.length != 6)
            return false;

        CloudToMongoWorker.cloud_server = args[0];
        CloudToMongoWorker.cloud_topic = args[1];
        CloudToMongoWorker.mongoURI = args[2];
        CloudToMongoWorker.mongo_database = args[3];
        CloudToMongoWorker.collectionPersonalized = new CollectionPersonalized(args[4]);
        CloudToMongoWorker.enable_window = args[5].equals("true");

        return true;
    }

    private void setAutoIncrement() {
        int initialValue = 0;

        if (db.getCollection(collectionPersonalized.getCollectionName()).count() != 0)
            initialValue = getAutoIncrement(collectionPersonalized.getCollectionName());

        collectionPersonalized.setInitialValue(initialValue);
    }

    private int getAutoIncrement(String collection) {
        return db.getCollection(collection)
                .aggregate(Arrays.asList(new Document("$project", new Document("Indice", 1)),
                        new Document("$sort", new Document("Indice", -1)), new Document("$limit", 1)))
                .first().getInteger("Indice") + 1;
    }

    /**
     * Creates a basic GUI
     */
    private static void createWindow() {
        JFrame frame = new JFrame("Cloud to Mongo - " + collectionPersonalized.getCollectionName());
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        JLabel textLabel = new JLabel("Data from broker: ", SwingConstants.CENTER);
        textLabel.setPreferredSize(new Dimension(600, 30));
        JScrollPane scroll = new JScrollPane(documentLabel, JScrollPane.VERTICAL_SCROLLBAR_ALWAYS,
                JScrollPane.HORIZONTAL_SCROLLBAR_ALWAYS);
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

    /**
     * Connects to Mqtt Broker
     */
    public void connectCloud() {
        int i = 1;
        try {
            i = new Random().nextInt(100000); // Comentar para testar
            mqttclient = new MqttClient(cloud_server,
                    "CloudToMongo_" + String.valueOf(i) + "_" + "pisid_grupo12");
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
        mongoClient = new MongoClient(new MongoClientURI(mongoURI));
        db = mongoClient.getDatabase(mongo_database);
    }

    public void closeMongo() {
        db = null;
        mongoClient.close();
    }

    private String transformToAtributesToString(String json) {
        String[] atributos = json.substring(1, json.length() - 1).split(",");
        String result = "{";
        int last = atributos.length - 1;
        for (int i = 0; i < last; i++)
            result += transformAtributeToString(atributos[i]) + ", ";

        return result + transformAtributeToString(atributos[last]) + "}";
    }

    private String transformAtributeToString(String attribute) {
        String[] cutAttribute = attribute.split(":", 2);
        String value = cutAttribute[1].trim();
        value = value.charAt(0) == '"' ? value : "\"" + value + "\"";
        return cutAttribute[0] + ": " + value;
    }

    // MqttCallback
    /**
     *
     * @param topic The topic that we have received
     * @param c     MqttMessage, it is already in a json format that is why we
     *              create a document to using Json.parse
     * @throws Exception
     */
    @Override
    public void messageArrived(String topic, MqttMessage c) throws Exception {
        try {
            Document document_json = Document.parse(transformToAtributesToString(c.toString()));

            document_json.put("Indice", collectionPersonalized.getAndIncrement());

            MongoCollection<Document> mongocol = db
                    .getCollection(collectionPersonalized.getCollectionName());
            mongocol.insertOne(document_json);

            documentLabel.append(c.toString() + "\n");
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
            System.out.println(transformToAtributesToString(c.toString()));
        }
    }

    @Override
    public void connectionLost(Throwable cause) {
        // throw new UnsupportedOperationException("Unimplemented method
        // 'connectionLost'");
    }

    @Override
    public void deliveryComplete(IMqttDeliveryToken token) {
        // throw new UnsupportedOperationException("Unimplemented method
        // 'deliveryComplete'");
    }
}
