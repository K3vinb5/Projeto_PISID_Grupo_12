
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Properties;

import javax.swing.JOptionPane;

import org.bson.Document;

import com.mongodb.MongoClient;
import com.mongodb.MongoClientURI;
import com.mongodb.client.MongoDatabase;

/**
 * @author Grupo12
 * @version 1.0
 */
public class CloudToMongo {

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
    static String enable_window = "";
    static List<String> mongo_collections = new ArrayList<>();
    static List<String> cloud_topics = new ArrayList<>();
    static String javaPath = "java";
    static String relativePath = "cloudToMongo.CloudToMongoWorker";
    static String mongoURI = "";

    public static void main(String[] args) {
        try {
            Properties p = new Properties();
            p.load(new FileInputStream(System.getProperty("user.dir") + "\\..\\..\\CloudToMongo.ini"));
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
            enable_window = p.getProperty("enable_window");
        } catch (Exception e) {
            System.out.println("Error reading CloudToMongo.ini file " + e);
            JOptionPane.showMessageDialog(null, "The CloudToMongo.ini file wasn't found.", "CloudToMongo",
                    JOptionPane.ERROR_MESSAGE);
            System.exit(1);
        }

        CloudToMongo c = new CloudToMongo();
        c.connectMongo();

        c.doAction();

        c.closeMongo();
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

    public void closeMongo() {
        db = null;
        mongoClient.close();
    }

    private void doAction() {
        List<String> collectionsInDataBase = db.listCollectionNames().into(new ArrayList<String>());
        for (int i = 0; i < mongo_collections.size(); i++) {
            String topic = cloud_topics.get(i);
            String collection = mongo_collections.get(i);

            if (!collectionsInDataBase.contains(collection))
                createCollectionAndIndex(collection);

            runCloudToMongoWorker(
                    new String[] { cloud_server, topic, mongoURI, mongo_database, collection, enable_window });
        }
    }

    private void createCollectionAndIndex(String collection) {
        db.getCollection(collection).createIndex(new Document("Indice", -1));
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

}