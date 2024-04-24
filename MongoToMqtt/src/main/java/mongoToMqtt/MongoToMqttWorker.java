package mongoToMqtt;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Arrays;
import java.util.Date;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.SwingConstants;

import org.bson.Document;
import org.bson.types.ObjectId;
import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.MqttMessage;

import com.mongodb.MongoClient;
import com.mongodb.MongoClientURI;
import com.mongodb.client.AggregateIterable;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.changestream.ChangeStreamDocument;

public class MongoToMqttWorker {
    static private String cloud_server;
    static private String cloud_topic;
    static private String mongoURI;
    static private String mongo_database;
    static private String collection;
    static private String recoverFrom;
    static private MongoClient mongoClient;
    static private MongoDatabase db;
    static private MqttClient mqttclient;
    static private int pubQos;
    static JTextArea documentLabel = new JTextArea("\n");

    public static void main(String[] args) {
        if (!setAttibutes(args))
            return;

        createWindow();

        MongoToMqttWorker mqttSender = new MongoToMqttWorker();
        MongoToMqttWorker mongoReceiver = new MongoToMqttWorker();

        mongoReceiver.connectMongo();
        mqttSender.connectCloud();

        mongoReceiver.work();
    }

    /**
     * Creates a basic GUI
     */
    private static void createWindow() {
        JFrame frame = new JFrame("Mongo to Mqtt - " + collection);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        JLabel textLabel = new JLabel("Data from mongo: ", SwingConstants.CENTER);
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

    // Factory
    // [0] - cloud_server,
    // [1] - cloud_topic,
    // [2] - mongoURI,
    // [3] - mongo_database,
    // [4] - collection,
    // [5] - pubQos,
    // [6] - recoverFrom
    private static boolean setAttibutes(String[] args) {
        if (args == null || args.length != 7)
            return false;

        Integer qos;
        try {
            qos = Integer.parseInt(args[5]);
        } catch (NumberFormatException e) {
            return false;
        }

        MongoToMqttWorker.cloud_server = args[0];
        MongoToMqttWorker.cloud_topic = args[1];
        MongoToMqttWorker.mongoURI = args[2];
        MongoToMqttWorker.mongo_database = args[3];
        MongoToMqttWorker.collection = args[4];
        MongoToMqttWorker.pubQos = qos;
        MongoToMqttWorker.recoverFrom = args[6];

        return true;
    }

    /**
     * Connects to Mqtt Broker
     */
    public void connectCloud() {
        int i = 1;
        try {
            // i = new Random().nextInt(100000); // Comentar para testar
            mqttclient = new MqttClient(cloud_server,
                    "CloudToMongo_" + String.valueOf(i) + "_" + "pisid_grupo12");
            mqttclient.connect();
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

    private void sendInitialData() {
        MongoCursor<Document> it = getData().iterator();
        while (it.hasNext()) {
            Document document = it.next();
            sendMessage(encript(document.toJson()));
        }
    }

    private AggregateIterable<Document> getData() {
        Document objectMatch = new Document("_id", new Document("$gt", getObjectIdToSearch()));
        return db.getCollection(collection)
                .aggregate(Arrays.asList(new Document("$match",
                        objectMatch),
                        new Document("$sort", new Document("_id", 1))));
    }

    private static ObjectId getObjectIdToSearch() {
        long miliSeconds;
        try {
            miliSeconds = System.currentTimeMillis() - Long.parseLong(recoverFrom) * 1000;
        } catch (NumberFormatException e) {
            return null;
        }
        return new ObjectId(new Date(miliSeconds));
    }

    // TODO encriptar dados
    private String encript(String msg) {
        return msg;
    }

    private void work() {
        sendInitialData();

        MongoCursor<ChangeStreamDocument<Document>> it = db.getCollection(collection).watch()
                .iterator();
        ChangeStreamDocument<Document> changeStreamDoc = null;

        while (it.hasNext()) {
            changeStreamDoc = it.next();
            Document document = changeStreamDoc.getFullDocument();
            if (document != null) { // Only enter if is insert
                sendMessage(encript(document.toJson()));
            }
        }
    }

    public void sendMessage(String msg) {
        MqttMessage message = new MqttMessage(msg.getBytes());
        message.setQos(pubQos);
        try {
            mqttclient.publish(cloud_topic, message);
            documentLabel.append(msg);
        } catch (MqttException e) {
            System.out.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
