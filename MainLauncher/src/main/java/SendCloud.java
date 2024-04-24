import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import javax.swing.JOptionPane;

import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.MqttMessage;

import com.mongodb.MongoClient;
import com.mongodb.MongoClientURI;
import com.mongodb.client.MongoDatabase;

/**
 * @author Grupo12
 * @version 1.0
 */
public class SendCloud {
    static MqttClient mqttclient;
    static String cloud_server = "";
    static String cloud_topic = "";
    static MongoClient mongoClient;
    static MongoDatabase db;
    static String mongo_user = "";
    static String mongo_password = "";
    static String mongo_address = "";
    static String mongo_host = "";
    static String mongo_replica = "";
    static String mongo_database = "";
    static String mongo_authentication = "";
    static String javaPath = "java";
    static String relativePath = "mongoToMqtt.MontoToMqttWorker";
    static String mongoURI = "";
    static List<String> mongo_collections = new ArrayList<>();
    static List<String> cloud_topics = new ArrayList<>();

    /**
     * Publishes a message to the topic specified in the .ini file
     * 
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

    public static void main(String[] args) {

        try {
            Properties p = new Properties();
            p.load(new FileInputStream("SendCloud.ini"));
            cloud_server = p.getProperty("cloud_server");
            cloud_topic = p.getProperty("cloud_topic");
            mongo_address = p.getProperty("mongo_address");
            mongo_user = p.getProperty("mongo_user");
            mongo_password = p.getProperty("mongo_password");
            mongo_replica = p.getProperty("mongo_replica");
            mongo_host = p.getProperty("mongo_host");
            mongo_database = p.getProperty("mongo_database");
            mongo_authentication = p.getProperty("mongo_authentication");
        } catch (Exception e) {

            System.out.println("Error reading SendCloud.ini file " + e);
            JOptionPane.showMessageDialog(null, "The SendCloud.ini file wasn't found.", "Send Cloud",
                    JOptionPane.ERROR_MESSAGE);
        }
        new SendCloud().connectMongo();

    }

    /**
     * Connects to Mongo DataBase specified in .ini file
     */
    public void connectMongo() {
        mongoURI = "mongodb://";

        if (mongo_authentication.equals("true"))
            mongoURI = mongoURI + mongo_user + ":" + mongo_password + "@";

        mongoURI = mongoURI + mongo_address;

        if (!mongo_replica.equals("false"))
            mongoURI += "/?replicaSet=" + mongo_replica;

        mongoClient = new MongoClient(new MongoClientURI(mongoURI));
        db = mongoClient.getDatabase(mongo_database);

    }

    public void runCloudToMongoWorker(String[] arguments) {
        try {
            String home = System.getProperty("user.home");
            ProcessBuilder pb = new ProcessBuilder(javaPath, "-cp",
                    ".;" + home
                            + "\\.m2\\repository\\org\\eclipse\\paho\\org.eclipse.paho.client.mqttv3\\1.1.0\\org.eclipse.paho.client.mqttv3-1.1.0.jar;"
                            + home
                            + "\\.m2\\repository\\org\\mongodb\\mongo-java-driver\\3.6.3\\mongo-java-driver-3.6.3.jar;"
                            + home + "\\.m2\\repository\\org\\mongodb\\bson\\3.10.1\\bson-3.10.1.jar",
                    relativePath);
            pb.directory(new File(System.getProperty("user.dir")));
            pb.command().addAll(List.of(arguments));

            pb.start();

        } catch (IOException e) {
            System.err.println(e.getMessage());
        }

    }

    private void doAction() {
        List<String> collectionsInDataBase = db.listCollectionNames().into(new ArrayList<String>());
        for (int i = 0; i < mongo_collections.size(); i++) {
            String topic = cloud_topics.get(i);
            String collection = mongo_collections.get(i);

            // if (!collectionsInDataBase.contains(collection))
            // createCollectionAndIndex(collection);

            // runCloudToMongoWorker(
            // new String[] { cloud_server, topic, mongoURI, mongo_database, collection,
            // enable_window });
        }
    }
}