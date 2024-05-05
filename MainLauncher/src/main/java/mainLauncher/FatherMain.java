package mainLauncher;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Properties;

import javax.swing.JOptionPane;

/**
 * @author Grupo12
 * @version 1.0
 */
public class FatherMain {

    // public static class ProcessBundle {
    // private Process process;
    // private ProcessBuilder processBuilder;

    // ProcessBundle(Process process, ProcessBuilder processBuilder) {
    // this.process = process;
    // this.processBuilder = processBuilder;
    // }

    // public void setProcess(Process process) {
    // this.process = process;
    // }

    // }

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
    static List<String> pubQos = new ArrayList<>();
    static String recoverFrom = "";
    static String sql_database_connection_to = "";
    static String sql_database_user_to = "";
    static String sql_database_password_to = "";
    static List<String> sql_tables = new ArrayList<>();
    static List<String> spNames = new ArrayList<>();
    static String javaPath = "java";
    static String relativePath = "";
    static String mongoURI = "";
    static Manager manager;
    static List<String> tipoMedicoes = new ArrayList<>();
    static List<String> spValidates = new ArrayList<>();
    static List<String> sql_database_connection_to_aux = new ArrayList<>();
    static List<String> sql_database_user_to_aux = new ArrayList<>();
    static List<String> sql_database_password_to_aux = new ArrayList<>();
    // static List<ProcessBundle> processesbBundles = new ArrayList<>();

    public static void main(String[] args) {
        if (!loadArgs(args))
            return;

        createMongoURI();

        manager.createAndRunWorkers();

        // checkChildren();

    }

    // static void checkChildren() {
    // while (true) {
    // try {
    // for (int i = 0; i < processesbBundles.size(); i++)
    // if (!processesbBundles.get(i).process.isAlive())
    // processesbBundles.get(i).setProcess(processesbBundles.get(i).processBuilder.start());

    // Thread.sleep(5000);
    // } catch (InterruptedException | IOException _) {
    // }
    // }
    // }

    // Factory
    // [0] - ini File
    // [1] - Program
    private static boolean loadArgs(String[] args) {
        if (args == null || args.length != 2)
            return false;

        Properties p = null;
        try {
            p = loadIni(args[0]);
        } catch (Exception e) {
            System.out.println("Error reading CloudToMongo.ini file " + e);
            JOptionPane.showMessageDialog(null, "The CloudToMongo.ini file wasn't found.", "CloudToMongo",
                    JOptionPane.ERROR_MESSAGE);
            System.exit(1);
        }

        relativePath = args[1];
        // Better code here: args[0].split("\\\\|/")[2]
        String fileName = args[0].contains("/") ? args[0].split("/")[2] : args[0].split("\\\\|/")[2];
        switch (fileName) {
            case "CloudToMongo.ini":
                setMqttToMongo(p);
                manager = new Manager() {
                    @Override
                    public void createAndRunWorkers() {
                        for (int i = 0; i < mongo_collections.size(); i++) {
                            runWorker(
                                    new String[] { cloud_server, cloud_topics.get(i), mongoURI, mongo_database,
                                            mongo_collections.get(i), enable_window });
                        }
                    }
                };
                break;

            case "SendCloud.ini":
                setMongoToMqtt(p);
                manager = new Manager() {
                    @Override
                    public void createAndRunWorkers() {
                        for (int i = 0; i < mongo_collections.size(); i++) {
                            runWorker(
                                    new String[] { cloud_server, cloud_topics.get(i), mongoURI, mongo_database,
                                            mongo_collections.get(i), pubQos.get(i), recoverFrom, enable_window });

                        }
                    }
                };
                break;

            case "ReceiveCloud.ini":
                setMqttToMySQL(p);
                manager = new Manager() {
                    @Override
                    public void createAndRunWorkers() {
                        for (int i = 0; i < cloud_topics.size(); i++) {
                            runWorker(
                                    new String[] { cloud_server, cloud_topics.get(i),
                                            sql_tables.get(i),
                                            sql_database_connection_to,
                                            sql_database_user_to, sql_database_password_to, spNames.get(i),
                                            tipoMedicoes.get(i), spValidates.get(i),
                                            sql_database_connection_to_aux.get(i),
                                            sql_database_user_to_aux.get(i),
                                            sql_database_password_to_aux.get(i) });

                        }
                    }
                };
                break;

            default:
                return false;
        }

        return true;
    }

    private static Properties loadIni(String file) throws IOException {
        Properties p = new Properties();
        p.load(new FileInputStream(file));
        return p;
    }

    // Mqtt to Mongo
    // [0] - cloud_server,
    // [1] - cloud_topic,
    // [2] - mongoURI,
    // [3] - mongo_database,
    // [4] - collection,
    // [5] - enable_window
    private static void setMqttToMongo(Properties p) {
        cloud_server = p.getProperty("cloud_server");
        cloud_topics = Arrays.stream(p.getProperty("cloud_topics").split(",")).toList();
        mongo_authentication = p.getProperty("mongo_authentication");
        mongo_address = p.getProperty("mongo_address");
        mongo_user = p.getProperty("mongo_user");
        mongo_password = p.getProperty("mongo_password");
        mongo_replica = p.getProperty("mongo_replica");
        mongo_host = p.getProperty("mongo_host");
        mongo_database = p.getProperty("mongo_database");
        mongo_collections = Arrays.stream(p.getProperty("mongo_collections").split(",")).toList();
        enable_window = p.getProperty("enable_window");
    }

    // Mongo to Mqtt
    // [0] - cloud_server,
    // [1] - cloud_topic,
    // [2] - mongoURI,
    // [3] - mongo_database,
    // [4] - collection,
    // [5] - pubQos,
    // [6] - recoverFrom
    private static void setMongoToMqtt(Properties p) {
        cloud_server = p.getProperty("cloud_server");
        cloud_topics = Arrays.stream(p.getProperty("cloud_topics").split(",")).toList();
        mongo_authentication = p.getProperty("mongo_authentication");
        mongo_address = p.getProperty("mongo_address");
        mongo_user = p.getProperty("mongo_user");
        mongo_password = p.getProperty("mongo_password");
        mongo_replica = p.getProperty("mongo_replica");
        mongo_host = p.getProperty("mongo_host");
        mongo_database = p.getProperty("mongo_database");
        mongo_collections = Arrays.stream(p.getProperty("mongo_collections").split(",")).toList();
        pubQos = Arrays.stream(p.getProperty("qos_topic").split(",")).toList();
        recoverFrom = p.getProperty("recoverFrom");
        enable_window = p.getProperty("enable_window");
    }

    // Mqtt to mySQL
    // [0] - cloud_server
    // [1] - cloud_topic
    // [2] - sql_table_to
    // [3] - sql_database_connection_to
    // [4] - sql_database_user_to
    // [5] - sql_database_password_to
    // [6] - spName
    // [7] - tipoMedicao
    // [8] - spValidate
    // [9] - sql_database_connection_to_aux
    // [10] - sql_database_user_to_aux
    // [11] - sql_database_password_to_aux
    private static void setMqttToMySQL(Properties p) {
        cloud_server = p.getProperty("cloud_server");
        cloud_topics = Arrays.stream(p.getProperty("cloud_topics").split(",")).toList();
        sql_tables = Arrays.stream(p.getProperty("sql_tables").split(",")).toList();
        sql_database_connection_to = p.getProperty("sql_database_connection_to");
        sql_database_user_to = p.getProperty("sql_database_user_to");
        sql_database_password_to = p.getProperty("sql_database_password_to");
        spNames = Arrays.stream(p.getProperty("spNames").split(",")).toList();
        tipoMedicoes = Arrays.stream(p.getProperty("tipoMedicoes").split(",")).toList();
        spValidates = Arrays.stream(p.getProperty("spValidates").split(",")).toList();
        sql_database_connection_to_aux = Arrays.stream(p.getProperty("sql_database_connection_to_aux").split(","))
                .toList();
        sql_database_user_to_aux = Arrays.stream(p.getProperty("sql_database_user_to_aux").split(",")).toList();
        sql_database_password_to_aux = Arrays.stream(p.getProperty("sql_database_password_to_aux").split(",")).toList();
    }

    /**
     * Connects to Mongo DataBase specified in .ini file
     */
    public static void createMongoURI() {
        mongoURI = "mongodb://";

        if (mongo_authentication.equals("true"))
            mongoURI = mongoURI + mongo_user + ":" + mongo_password + "@";

        mongoURI = mongoURI + mongo_address;

        if (!mongo_replica.equals("false"))
            mongoURI += "/?replicaSet=" + mongo_replica;
    }

    public static void runWorker(String[] arguments) {
        // TODO fix this mess (Kevin ended up doing it, cause Alex sucks "É fodido
        // joca")
        String separator = System.getProperty("os.name") == "Linux" ? ":" : ";";
        try {
            ProcessBuilder pb = new ProcessBuilder(javaPath, "-cp",
                    ".//lib//org.eclipse.paho.client.mqttv3-1.1.0.jar" + separator
                            + ".//lib//mongo-java-driver-3.12.14.jar" + separator + ".//lib//bson-4.11.0.jar"
                            + separator + ".//lib//mongodb-driver-sync-4.0.0.jar"
                            + separator
                            + ".//lib//gson-2.10.1.jar" + separator
                            + ".//lib//mariadb-java-client-3.3.3.jar" + separator
                            + ".//lib//mysql-connector-j-8.3.0.jar" + separator
                            + ".//lib//slf4j-api-2.0.13.jar" + separator
                            + ".//lib//mongodb-driver-core-4.0.0.jar" + separator
                            + ".",
                    relativePath);
            pb.command().addAll(List.of(arguments));
            pb.start();
        } catch (IOException e) {
            System.err.println(e.getMessage());
        }

    }

}