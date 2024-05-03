package testing;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.FileInputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Properties;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.SwingConstants;

import org.bson.Document;

import com.mongodb.MongoClient;
import com.mongodb.MongoClientURI;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;

public class Gen {
    static String limiteInferior = new String();
    static String limiteSuperior = new String();
    static String valorInicial = new String();
    static String variacao = new String();
    static String medicoesIguais = new String();
    static String medicoesEntreSalto = new String();
    static String valorSalto = new String();
    static String medicoesSalto = new String();
    static String zona = new String();
    static String sensor = new String();
    static JTextArea documentLabel = new JTextArea("\n");
    static private String collectionPersonalized;
    static private String mongoURI;
    static private MongoClient mongoClient;
    static private String mongo_database;
    static private MongoDatabase db;

    public static void main(String[] args) {
        createWindow();
        load();
        connectMongo();
        generateData();
    }

    /**
     * Creates a basic GUI
     */
    private static void createWindow() {
        JFrame frame = new JFrame("Ilegal Tests - " + collectionPersonalized);
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

    public static void load() {
        try {
            Properties var1 = new Properties();
            var1.load(new FileInputStream("Ilegal.ini"));
            zona = var1.getProperty("zona");
            sensor = var1.getProperty("sensor");
            valorInicial = var1.getProperty("valorInicial");
            limiteInferior = var1.getProperty("limiteInferior");
            limiteSuperior = var1.getProperty("limiteSuperior");
            variacao = var1.getProperty("variacao");
            medicoesIguais = var1.getProperty("medicoesIguais");
            medicoesEntreSalto = var1.getProperty("medicoesEntreSalto");
            valorSalto = var1.getProperty("valorSalto");
            medicoesSalto = var1.getProperty("medicoesSalto");
            mongo_database = var1.getProperty("mongo_database");
            collectionPersonalized = var1.getProperty("collection");
            System.err.println(collectionPersonalized);
            mongoURI = "mongodb://root:root_grupo12@localhost:27017/?replicaSet=replicaPISID";
        } catch (Exception var2) {
            System.out.println("Error reading Ilegal.ini file " + var2);
        }
    }

    /**
     * Connects to Mongo DataBase specified in .ini file
     */
    public static void connectMongo() {
        mongoClient = new MongoClient(new MongoClientURI(mongoURI));
        db = mongoClient.getDatabase(mongo_database);
    }

    private static String transformToAtributesToString(String json) {
        String[] atributos = json.substring(1, json.length() - 1).split(",");
        String result = "{";
        int last = atributos.length - 1;
        for (int i = 0; i < last; i++)
            result += transformAtributeToString(atributos[i]) + ", ";

        return result + transformAtributeToString(atributos[last]) + "}";
    }

    private static String transformAtributeToString(String attribute) {
        String[] cutAttribute = attribute.split(":", 2);
        String value = cutAttribute[1].trim();
        value = value.charAt(0) == '"' ? value : "\"" + value + "\"";
        return cutAttribute[0] + ": " + value;
    }

    public static void writeMongo(String c) {
        try {
            Document document_json = Document.parse(transformToAtributesToString(c.toString()));

            MongoCollection<Document> mongocol = db
                    .getCollection(collectionPersonalized);
            mongocol.insertOne(document_json);

            documentLabel.append(c.toString() + "\n");
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
            System.out.println(transformToAtributesToString(c.toString()));
        }
    }

    public static void generateData() {
        double var1 = 0.0;
        double var3 = Double.parseDouble(variacao);
        double var5 = Double.parseDouble(medicoesEntreSalto);
        double var7 = Double.parseDouble(limiteSuperior);
        double var9 = Double.parseDouble(limiteInferior);
        SimpleDateFormat var11 = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
        int var16 = 0;
        double var17 = 0.0;
        int var19 = 0;
        byte var20 = 1;
        var1 = Double.parseDouble(valorInicial);
        new Date(System.currentTimeMillis());

        while (true) {
            String var12;
            Date var21;
            do {
                var21 = new Date(System.currentTimeMillis());
                var12 = "{";
                var12 = var12 + "Data: \"" + var11.format(var21) + "\", ";
                var12 = var12 + "Leitura: \"" + var1 + "\", ";
                var12 = var12 + "Sensor: \"" + sensor + "\"";
                var12 = var12 + "}";

                writeMongo(var12);

                if (var20 == 1 && var1 > var7) {
                    var20 = 4;
                }

                if (var20 == 0 && var1 < var9) {
                    var20 = 3;
                }

                if (var20 > 2) {
                    ++var16;
                }

                if (var20 == 4 && var16 > Integer.parseInt(medicoesIguais)) {
                    var20 = 0;
                    var16 = 0;
                }

                if (var20 == 3 && var16 > Integer.parseInt(medicoesIguais)) {
                    var20 = 1;
                    var16 = 0;
                }

                if (var20 == 1) {
                    var1 += var3;
                }

                if (var20 == 0) {
                    var1 -= var3;
                }

                ++var19;
            } while (!((double) var19 > var5));

            for (int var13 = 0; var13 < Integer.parseInt(medicoesSalto); ++var13) {
                var21 = new Date(System.currentTimeMillis());
                var12 = "{";
                var12 = var12 + "Data: \"" + var11.format(var21) + "\", ";
                var12 = var12 + "Leitura: \"" + var17 + "\", ";
                var12 = var12 + "Sensor: \"" + sensor + "\"";
                var12 = var12 + "}";

                writeMongo(var12);

                try {
                    Thread.sleep((long) 1000);
                } catch (Exception var25) {
                }
            }
        }
    }
}
