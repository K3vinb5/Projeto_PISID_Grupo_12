package insertSQL;

import org.bson.BsonDocument;
import org.bson.BsonString;
import org.eclipse.paho.client.mqttv3.*;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedList;
import java.util.List;
import java.util.Random;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.SwingConstants;

import org.bson.*;
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
    static WriteMysql sqlConectionAUX;
    static String spName;
    static LinkedList<BsonDocument> documentsToSend = new LinkedList<>();
    static JTextArea documentLabel = new JTextArea("\n");
    static String tipoMedicao = "";
    static String spValidate = "";
    static String sql_database_connection_to_aux = "";
    static String sql_database_user_to_aux = "";
    static String sql_database_password_to_aux = "";
    static OutlierDetector iqr;
    static AlertInserter alertInserter;

    private static void createWindow() {
        JFrame frame = new JFrame("Receive Cloud - " + tipoMedicao);
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

        sqlConection = new WriteMysql(sql_table_to, sql_database_connection_to, sql_database_user_to,
                sql_database_password_to);
        if (!sql_database_connection_to_aux.equals("false")) {
            sqlConectionAUX = new WriteMysql(null, sql_database_connection_to_aux, sql_database_user_to_aux,
                    sql_database_password_to_aux);
            sqlConectionAUX.connectDatabase_to();
        }

        new ReceiveCloud().connecCloud();

        // documentLabel.append(cloud_server + "\n");
        // documentLabel.append(cloud_topic + "\n");
        // documentLabel.append(sql_table_to + "\n");
        // documentLabel.append(sql_database_connection_to + "\n");
        // documentLabel.append(sql_database_user_to + "\n");
        // documentLabel.append(sql_database_password_to + "\n");
        // documentLabel.append(spName + "\n");
        // documentLabel.append(tipoMedicao + "\n");
        // documentLabel.append(spValidate + "\n");
        // documentLabel.append(sql_database_connection_to_aux + "\n");
        // documentLabel.append(sql_database_user_to_aux + "\n");
        // documentLabel.append(sql_database_password_to_aux + "\n");
        iqr = new OutlierDetector();
        alertInserter = new AlertInserter(sqlConection);
        // sqlConection.connectDatabase_to();

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
    // [9] - sql_database_connection_to_aux
    // [10] - sql_database_user_to_aux
    // [11] - sql_database_password_to_aux
    private static boolean loadArgs(String[] args) {
        if (args == null || args.length != 12)
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
        ReceiveCloud.sql_database_connection_to_aux = args[9];
        ReceiveCloud.sql_database_user_to_aux = args[10];
        ReceiveCloud.sql_database_password_to_aux = args[11];

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
        sqlConection.connectDatabase_to();
        // if (sqlConection.isDown())
        // sqlConection.connectDatabase_to();

        BsonDocument document = BsonDocument.parse(c.toString());
        documentsToSend.add(document);

        if (sqlConection.isDown())
            return;

        if (document.get("Solucao") != null) {
            // try {
            System.out.println("------ Solucao: " + document + " ------");
            // sqlConection.closeExp(41);
            // } catch (SQLException e) {
            // e.printStackTrace();
            // }
        }

        try {
            sendMessages(!spValidate.equals("false"), !sql_database_connection_to_aux.equals("false"));
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            sqlConection.close();
            // System.out.println(Math.random());
        }
    }

    private void sendMessages(boolean enableSPValidation, boolean enableAuxBDValidation) throws SQLException {
        try {

            boolean callWrongValues = false;
            String tipoDado = "Dado Errado";
            while (!documentsToSend.isEmpty()) {
                callWrongValues = false;
                if (enableSPValidation
                        && (!sqlConection.isSensorValid(spValidate, documentsToSend.getFirst())
                                || !sqlConection.isDouble(
                                        (((BsonString) documentsToSend.getFirst().get("Leitura")).getValue()))))
                    callWrongValues = true;

                if (enableAuxBDValidation && !sqlConectionAUX.isDown()
                        && !sqlConectionAUX.isMovementValid(documentsToSend.getFirst()))
                    callWrongValues = true;

                if (enableSPValidation && !callWrongValues
                        && iqr.checkOutlier(Double
                                .parseDouble((((BsonString) documentsToSend.getFirst().get("Leitura")).getValue())))) {
                    tipoDado = "Outlier";
                    callWrongValues = true;
                }

                if (enableSPValidation && !callWrongValues) {
                    ResultSet currentExp = sqlConection.getCurrentExp();
                    if (currentExp.next()) {
                        alertInserter.addMeasurement(documentsToSend.getFirst(), currentExp);
                    }
                }

                if (!callWrongValues && !sqlConection.CallToMySQL(spName, documentsToSend.getFirst()))
                    callWrongValues = true;

                if (callWrongValues && !sqlConection.CallInsertWrongValues(tipoMedicao,
                        tipoDado,
                        documentsToSend.getFirst()))
                    return;

                documentLabel.append(documentsToSend.getFirst().toJson().toString() + "\n");
                documentsToSend.removeFirst();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    @Override
    public void connectionLost(Throwable cause) {
    }

    @Override
    public void deliveryComplete(IMqttDeliveryToken token) {
    }
}