import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.io.*;
import java.util.*;
import java.sql.*;
import javax.swing.*;
import java.awt.event.*;
import java.awt.*;

/**
 * @author kevin
 * @version 1.0
 */
public class WriteMysql {

    public static JTextArea documentLabel = new JTextArea("\n");
    public static Connection connTo;
    public static String sql_database_connection_to = "";
    public static String sql_database_password_to = "";
    public static String sql_database_user_to = "";

    public static String sql_table_to = "";


    private static void createWindow() {
        JFrame frame = new JFrame("Data Bridge");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        JLabel textLabel = new JLabel("Data : ", SwingConstants.CENTER);
        textLabel.setPreferredSize(new Dimension(600, 30));
        JScrollPane scroll = new JScrollPane(documentLabel, JScrollPane.VERTICAL_SCROLLBAR_ALWAYS, JScrollPane.HORIZONTAL_SCROLLBAR_ALWAYS);
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
        //createWindow();
        try {
            Properties p = new Properties();
            p.load(new FileInputStream("WriteMysql.ini"));

            sql_table_to = p.getProperty("sql_table_to");
            sql_database_connection_to = p.getProperty("sql_database_connection_to");
            sql_database_user_to = p.getProperty("sql_database_user_to");

            if (!sql_database_password_to.equals("false")) {
                sql_database_password_to = p.getProperty("sql_database_password_to");
            }

        } catch (Exception e) {
            System.out.println("Error reading WriteMysql.ini file " + e);
            JOptionPane.showMessageDialog(null, "The WriteMysql inifile wasn't found.", "Data Migration", JOptionPane.ERROR_MESSAGE);
        }
        new WriteMysql().connectDatabase_to();
        new WriteMysql().ReadData();
    }

    /**
     * Converts given Json to a Sql insert Command
     *
     * @param json A Json in a String format
     * @return A Sql Insert command where the columns are the keys and the values the entries
     */
    private static String JsonToSqlInsertCommand(String json) {
        JsonObject jsonObject = new Gson().fromJson(json, JsonObject.class);
        String fields = "(";
        String values = "(";

        for (Map.Entry<String, JsonElement> entry : jsonObject.entrySet()) {
            fields += entry.getKey() + ", ";
            values += entry.getValue().toString() + ", ";
        }
        fields = fields.substring(0, fields.length() - 2) + ")";
        values = values.substring(0, values.length() - 2) + ")";

        return "Insert into " + sql_table_to + " " + fields + " values " + values + ";";
    }

    public void connectDatabase_to() {
        try {
            Class.forName("org.mariadb.jdbc.Driver");
            connTo = DriverManager.getConnection(sql_database_connection_to, sql_database_user_to, sql_database_password_to);

            //GUI Stuff
            //documentLabel.append("SQl Connection:"+sql_database_connection_to+"\n");
            //documentLabel.append("Connection To MariaDB Destination " + sql_database_connection_to + " Suceeded"+"\n");

        } catch (Exception e) {
            System.out.println("Mysql Server Destination down, unable to make the connection. " + e);
        }
    }

    public void ReadData() {
        String doc;
        int i = 0;
        while (i < 100) {
            doc = "{Name:\"Nome_" + i + "\", Location:\"Portugal\", id:" + i + "}";
            //WriteToMySQL(com.mongodb.util.JSON.serialize(doc));
            WriteToMySQL(doc);
            i++;
        }
    }

    public void WriteToMySQL(String json) {
        String SqlInsertCommand = JsonToSqlInsertCommand(json);

        //GUI Stuff
        /*try {
            documentLabel.append(SqlCommand.toString()+"\n");
        } catch (Exception e) {
            System.out.println(e);
        }*/

        try {
            Statement s = connTo.createStatement();
            s.executeUpdate(SqlInsertCommand);
            s.close();
        } catch (Exception e) {
            System.err.println("Error Inserting in the database . " + e);
            System.err.println(SqlInsertCommand);
        }
    }


}