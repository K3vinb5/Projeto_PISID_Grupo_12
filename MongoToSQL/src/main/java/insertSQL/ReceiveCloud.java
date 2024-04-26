package insertSQL;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.FileInputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.LinkedList;
import java.util.List;
import java.util.Properties;
import java.util.Random;

import javax.print.DocFlavor.STRING;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.SwingConstants;

import org.bson.BsonDocument;
import org.bson.BsonValue;
import org.eclipse.paho.client.mqttv3.IMqttDeliveryToken;
import org.eclipse.paho.client.mqttv3.MqttCallback;
import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.MqttMessage;

public class ReceiveCloud implements MqttCallback {
    MqttClient mqttclient;
    static String cloud_server = "";
    static String cloud_topic = "";
    public static Connection connTo;
    public static String sql_database_connection_to = "";
    public static String sql_database_password_to = "";
    public static String sql_database_user_to = "";
    public static String sql_table_to = "";
    static WriteMysql sqlConection;
    static String spName;
    static List<BsonDocument> documentsSent = new LinkedList<>();
    static JTextArea documentLabel = new JTextArea("\n");
    static String spNameWrong = "";
    static String spValidate = "";

    private static void createWindow() {
        JFrame frame = new JFrame("Receive Cloud");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        JLabel textLabel = new JLabel("Data from broker: ", SwingConstants.CENTER);
        textLabel.setPreferredSize(new Dimension(600, 30));
        documentLabel.setPreferredSize(new Dimension(600, 200));
        JScrollPane scroll = new JScrollPane(documentLabel,
                JScrollPane.VERTICAL_SCROLLBAR_ALWAYS, JScrollPane.HORIZONTAL_SCROLLBAR_ALWAYS);
        frame.add(scroll);
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
        // Converter para args
        try {
            Properties p = new Properties();
            p.load(new FileInputStream("ReceiveCloud.ini"));
            cloud_server = p.getProperty("cloud_server");
            cloud_topic = p.getProperty("cloud_topic");
            sql_table_to = p.getProperty("sql_table_to");
            sql_database_connection_to = p.getProperty("sql_database_connection_to");
            sql_database_user_to = p.getProperty("sql_database_user_to");
            sql_database_password_to = p.getProperty("sql_database_password_to");
            spName = p.getProperty("spName");
            spNameWrong = p.getProperty("spNameWrong");
            spValidate = p.getProperty("spValidate");
        } catch (Exception e) {
            System.out.println("Error reading ReceiveCloud.ini file " + e);
            JOptionPane.showMessageDialog(null, "The ReceiveCloud.ini file wasn't found.", "Receive Cloud",
                    JOptionPane.ERROR_MESSAGE);
        }
        new ReceiveCloud().connecCloud();

        sqlConection = new WriteMysql(sql_table_to, sql_database_connection_to, sql_database_user_to,
                sql_database_password_to);
        sqlConection.connectDatabase_to();
    }

    public void connecCloud() {
        int i = 1;
        try {
            i = new Random().nextInt(100000);
            mqttclient = new MqttClient(cloud_server, "ReceiveCloud" + i + "_" + cloud_topic);
            mqttclient.connect();
            mqttclient.setCallback(this);
            mqttclient.subscribe(cloud_topic);
        } catch (MqttException e) {
            e.printStackTrace();
        }
    }

    // TODO Se tiver "Sensor" no BSON procura na bd
    @Override
    public void messageArrived(String topic, MqttMessage c) {
        BsonDocument document = BsonDocument.parse(c.toString());
        documentsSent.add(document);

        try {
            if (!callSPValidation(spValidate, documentsSent.getFirst())
                    && !callCRUD(spName, documentsSent.getFirst())
                    && !callCRUD(spNameWrong, documentsSent.getFirst()))
                return;
        } catch (SQLException e) {
            return;
        }

        documentLabel.append(c.toString() + "\n");
        documentsSent.removeFirst();
    }

    private boolean callSPValidation(String sp, BsonDocument document) throws SQLException {
        return sqlConection.CallToMySQL(sp, document, true);
    }

    private boolean callCRUD(String sp, BsonDocument document) throws SQLException {
        return sqlConection.CallToMySQL(sp, document, false);
    }

    @Override
    public void connectionLost(Throwable cause) {
    }

    @Override
    public void deliveryComplete(IMqttDeliveryToken token) {
    }
}