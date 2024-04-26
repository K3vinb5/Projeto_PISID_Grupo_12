package insertSQL;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

import java.io.*;
import java.util.*;
import java.util.Date;
import java.util.List;
import java.sql.*;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;

import javax.print.DocFlavor.STRING;
import javax.swing.*;

import org.bson.BsonDocument;
import org.bson.BsonString;
import org.bson.BsonValue;
import org.bson.conversions.Bson;

import java.awt.event.*;
import java.awt.*;

/**
 * @author Grupo12
 * @version 1.0
 */
public class WriteMysql {

    public static JTextArea documentLabel = new JTextArea("\n");
    public static Connection connTo;
    public static String sql_database_connection_to = "";
    public static String sql_database_password_to = "";
    public static String sql_database_user_to = "";
    static String database = "";

    public static String sql_table_to = "";

    public WriteMysql(String sql_table_to, String sql_database_connection_to, String sql_database_user_to,
            String sql_database_password_to) {
        WriteMysql.sql_table_to = sql_table_to;
        WriteMysql.sql_database_connection_to = sql_database_connection_to;
        WriteMysql.sql_database_user_to = sql_database_user_to;
        WriteMysql.sql_database_password_to = sql_database_password_to;
        String[] db_conect = sql_database_connection_to.split("/");
        WriteMysql.database = db_conect[db_conect.length - 1];
    }

    private static void createWindow() {
        JFrame frame = new JFrame("Data Bridge");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        JLabel textLabel = new JLabel("Data : ", SwingConstants.CENTER);
        textLabel.setPreferredSize(new Dimension(600, 30));
        JScrollPane scroll = new JScrollPane(documentLabel,
                JScrollPane.VERTICAL_SCROLLBAR_ALWAYS,
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

    /**
     * Converts given Json to a Sql insert Command
     *
     * @param json A Json in a String format
     * @return A Sql Insert command where the columns are the keys and the values
     *         the entries
     */
    private static String JsonToSqlInsertCommand(String json) {
        JsonObject jsonObject = new Gson().fromJson(json,
                JsonObject.class);
        String fields = "(";
        String values = "(";

        for (Map.Entry<String, JsonElement> entry : jsonObject.entrySet()) {
            fields += entry.getKey() + ", ";
            values += entry.getValue().toString() + ", ";
        }
        fields = fields.substring(0, fields.length() - 2) + ")";
        values = values.substring(0, values.length() - 2) + ")";

        return "Insert into " + sql_table_to + " " + fields + " values " + values +
                ";";
    }

    private static String insertCommand(String json) {
        JsonObject jsonObject = new Gson().fromJson(json,
                JsonObject.class);
        String fields = "(";
        String values = "(";

        for (Map.Entry<String, JsonElement> entry : jsonObject.entrySet()) {
            fields += entry.getKey() + ", ";
            values += entry.getValue().toString() + ", ";
        }
        fields = fields.substring(0, fields.length() - 2) + ")";
        values = values.substring(0, values.length() - 2) + ")";

        return "Insert into " + sql_table_to + " " + fields + " values " + values +
                ";";
    }

    public void connectDatabase_to() {
        try {
            Class.forName("org.mariadb.jdbc.Driver");
            connTo = DriverManager.getConnection(sql_database_connection_to, sql_database_user_to,
                    sql_database_password_to);
            documentLabel.append("SQl Connection:" + sql_database_connection_to + "\n");
            documentLabel.append("Connection To MariaDB From Suceeded\n");
        } catch (Exception var2) {
            System.out.println("Mysql Server Origin down, unable to make the connection. " + var2.getMessage());
        }
    }

    public void ReadData() throws SQLException {
        String doc;
        int i = 0;
        while (i < 100) {
            doc = "{Name:\"Nome_" + i + "\", Location:\"Portugal\", id:" + i + "}";
            // WriteToMySQL(com.mongodb.util.JSON.serialize(doc));
            insertToMySQL(doc);
            i++;
        }
    }

    public boolean CallToMySQL(String spName, BsonDocument document, boolean isValidation) throws SQLException {
        ResultSet rs = getSchemaSP(spName);

        List<String> params = new ArrayList<>();
        List<String> types = new ArrayList<>();
        while (rs.next()) {
            params.add(rs.getString("PARAMETER_NAME"));
            types.add(rs.getString("DATA_TYPE"));
        }

        String sql = "{call " + spName + "(";
        for (int i = 0; i < params.size(); i++)
            sql += "?,";

        if (params.size() > 0)
            sql = sql.substring(0, sql.length() - 1);

        sql += ")}";

        CallableStatement stmt = connTo.prepareCall(sql);

        for (int i = 1; i <= params.size(); i++) {
            BsonValue value = document.get(params.get(i - 1));
            System.err.println(value);
            if ((!types.get(i - 1).equals("datetime") && value == null)
                    || (value != null && !isDouble(((BsonString) value).getValue())
                            && !types
                                    .get(i - 1).equals("datetime")))
                return false;

            stmt.setString(i, value == null ? null : ((BsonString) value).getValue());
        }

        // Execute the stored procedure
        stmt.execute();
        if (isValidation) {
            stmt.getResultSet();

        }
        return true;
    }

    private boolean isDouble(String num) {
        try {
            Double.parseDouble(num);
        } catch (NumberFormatException e) {
            return false;
        }
        return true;
    }

    public void insertToMySQL(String json) throws SQLException {
        String SqlInsertCommand = JsonToSqlInsertCommand(json);

        // GUI Stuff
        /*
         * try {
         * documentLabel.append(SqlCommand.toString()+"\n");
         * } catch (Exception e) {
         * System.out.println(e);
         * }
         */

        execute(SqlInsertCommand);
    }

    public ResultSet getSchemaSP(String spName) throws SQLException {
        Statement stmt = connTo.createStatement();
        System.err.println(sql_database_connection_to);
        ResultSet rs = stmt
                .executeQuery(
                        "SELECT PARAMETER_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.PARAMETERS WHERE SPECIFIC_SCHEMA = \""
                                + database + "\" AND SPECIFIC_NAME = \"" + spName + "\";");

        return rs;
    }

    private void execute(String SqlInsertCommand) throws SQLException {
        Statement s = connTo.createStatement();
        s.executeUpdate(SqlInsertCommand);
        s.close();
    }

}