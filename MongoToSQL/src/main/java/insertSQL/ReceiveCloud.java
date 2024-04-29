package insertSQL;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.LinkedList;
import java.util.List;
import java.util.Properties;
import java.util.Random;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.SwingConstants;

import org.bson.BsonDocument;
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
    static List<BsonDocument> documentsToSend = new LinkedList<>();
    static JTextArea documentLabel = new JTextArea("\n");
    static String tipoMedicao = "";
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

        if (!loadArgs(args))
            return;

        createWindow();

        new ReceiveCloud().connecCloud();

        sqlConection = new WriteMysql(sql_table_to, sql_database_connection_to, sql_database_user_to,
                sql_database_password_to);
        sqlConection.connectDatabase_to();
    }

    // Factory
    // [0] - cloud_server
    // [1] - cloud_topic
    // [2] - sql_table_to
    // [3] - sql_database_connection_to
    // [4] - sql_database_user_to
    // [5] - sql_database_password_to
    // [6] - spName
    // [7] - tipoMedicao
    // [8] - spValidate
    private static boolean loadArgs(String[] args) {
        if (args == null || args.length != 9)
            return false;

        ReceiveCloud.cloud_server = args[0];
        ReceiveCloud.cloud_topic = args[1];
        ReceiveCloud.sql_table_to = args[2];
        ReceiveCloud.sql_database_connection_to = args[3];
        ReceiveCloud.sql_database_user_to = args[4];
        ReceiveCloud.sql_database_password_to = args[5];
        ReceiveCloud.spName = args[6];
        ReceiveCloud.tipoMedicao = args[7];
        ReceiveCloud.spValidate = args[8];

        return true;
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

    @Override
    public void messageArrived(String topic, MqttMessage c) {
        if (sqlConection.isDown())
            sqlConection.connectDatabase_to();
        BsonDocument document = BsonDocument.parse(c.toString());
        documentsToSend.add(document);

        try {
            sendMessages(!spValidate.equals("false"));
        } catch (SQLException e) {
        }
    }

    private void sendMessages(boolean enableSPValidation) throws SQLException {
        boolean callWrongValues = false;
        while (!documentsToSend.isEmpty()) {
            callWrongValues = false;
            if (enableSPValidation
                    && !sqlConection.isSensorValid(spValidate, documentsToSend.getFirst()))
                callWrongValues = true;

            if (!callWrongValues && !sqlConection.CallToMySQL(spName, documentsToSend.getFirst()))
                callWrongValues = true;

            if (callWrongValues && !sqlConection.CallInsertWrongValues(tipoMedicao, "Dado Errado",
                    documentsToSend.getFirst()))
                return;

            documentLabel.append(documentsToSend.getFirst().toJson().toString() + "\n");
            documentsToSend.removeFirst();
        }
    }

    @Override
    public void connectionLost(Throwable cause) {
    }

    @Override
    public void deliveryComplete(IMqttDeliveryToken token) {
    }
}