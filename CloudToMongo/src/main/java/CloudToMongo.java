import org.bson.Document;
import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;
import org.eclipse.paho.client.mqttv3.MqttCallback;
import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.MqttMessage;

import com.mongodb.*;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;

import javax.swing.*;
import java.util.*;

import java.io.*;
import java.awt.*;
import java.awt.event.*;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * @author Grupo12
 * @version 1.0
 */
public class CloudToMongo implements MqttCallback {

    /**
     * CollectionPersonalized
     */
    public static class CollectionPersonalized {
        private AtomicInteger autoIncrement;
        private String collectionName;

        CollectionPersonalized(String collectionName) {
            this.collectionName = collectionName;
        }

        void setInitialValue() {
            autoIncrement = new AtomicInteger(0);
        }

        void setInitialValue(int initalValue) {
            autoIncrement = new AtomicInteger(initalValue);
        }

        public int getAutoIncrement() {
            return autoIncrement.getAndIncrement();
        }

        public String getCollectionName() {
            return collectionName;
        }
    }

    static MongoClient mongoClient;
    static MongoDatabase db;
    static String mongo_user = "";
    static String mongo_password = "";
    static String mongo_address = "";
    static String cloud_server = "";
    static String mongo_host = "";
    static String mongo_replica = "";
    static String mongo_database = "";
    static String mongo_authentication = "";
    static List<CollectionPersonalized> mongo_collections = new ArrayList<>();
    static Map<String, Integer> cloud_topics = new HashMap<String, Integer>();
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
            initCloudTopics(p.getProperty("cloud_topics"));
            initMongoCollections(p.getProperty("mongo_collections"));
        } catch (Exception e) {
            System.out.println("Error reading CloudToMongo.ini file " + e);
            JOptionPane.showMessageDialog(null, "The CloudToMongo.ini file wasn't found.", "CloudToMongo",
                    JOptionPane.ERROR_MESSAGE);
            System.exit(1);
        }
        new CloudToMongo().connectMongo();
        new CloudToMongo().connecCloud();
    }

    /**
     * Connects to Mqtt Broker
     */
    public void connecCloud() {
        int i = 1;
        try {
            i = new Random().nextInt(100000); // Comentar para testar
            mqttclient = new MqttClient(cloud_server, "CloudToMongo_" + String.valueOf(i) + "_" + "pisid_grupo12");
            mqttclient.connect();
            mqttclient.setCallback(this);
            for (String cloud_topic : cloud_topics.keySet()) {
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
        String mongoURI = "mongodb://";

        if (mongo_authentication.equals("true"))
            mongoURI = mongoURI + mongo_user + ":" + mongo_password + "@";

        mongoURI = mongoURI + mongo_address;

        if (!mongo_replica.equals("false"))
            mongoURI += "/?replicaSet=" + mongo_replica;

        mongoClient = new MongoClient(new MongoClientURI(mongoURI));
        db = mongoClient.getDatabase(mongo_database);

        checkDataBaseState();
    }

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

            CollectionPersonalized collectionPersonalized = mongo_collections.get(cloud_topics.get(topic));
            document_json.put("Indice", collectionPersonalized.getAutoIncrement());

            MongoCollection<Document> mongocol = db
                    .getCollection(collectionPersonalized.collectionName);
            mongocol.insertOne(document_json);

            documentLabel.append(c.toString() + "\n");
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
            System.out.println(transformToAtributesToString(c.toString()));
        }
    }

    @Override
    public void connectionLost(Throwable cause) {
    }

    @Override
    public void deliveryComplete(IMqttDeliveryToken token) {
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

    private void checkDataBaseState() {
        List<String> collectionsInDataBase = db.listCollectionNames().into(new ArrayList<String>());
        mongo_collections.forEach(personalizedCollection -> {
            if (!collectionsInDataBase.contains(personalizedCollection.collectionName))
                createCollectionAndIndex(personalizedCollection);

            else if (db.getCollection(personalizedCollection.collectionName).count() == 0)
                personalizedCollection.setInitialValue();

            else
                getAutoIncrement(personalizedCollection);
        });
    }

    private void createCollectionAndIndex(CollectionPersonalized collection) {
        db.getCollection(collection.collectionName).createIndex(new Document("Indice", -1));
        collection.setInitialValue();
    }

    private void getAutoIncrement(CollectionPersonalized collection) {
        collection.setInitialValue(db.getCollection(collection.collectionName)
                .aggregate(Arrays.asList(new Document("$project", new Document("Indice", 1)),
                        new Document("$sort", new Document("Indice", -1)), new Document("$limit", 1)))
                .first().getInteger("Indice") + 1);
    }

    private static void initCloudTopics(String property) {
        AtomicInteger counter = new AtomicInteger(-1);
        Arrays.stream(property.split(",")).forEach(topic -> cloud_topics.put(topic, counter.incrementAndGet()));
    }

    private static void initMongoCollections(String property) {
        Arrays.stream(property.split(","))
                .forEach(collection -> mongo_collections.add(new CollectionPersonalized(collection)));
    }
}