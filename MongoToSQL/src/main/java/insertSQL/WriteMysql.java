package insertSQL;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.SwingConstants;

import org.bson.BsonDocument;
import org.bson.BsonString;
import org.bson.BsonValue;

import com.google.gson.Gson;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

/**
 * @author Grupo12
 * @version 1.0
 */
public class WriteMysql {

    /**
     * Sensor
     */
    public class Sensor {
        private String tipo;
        private String nome;
        private String id;

        Sensor(String tipo, String nome, String id) {
            this.tipo = tipo;
            this.nome = nome;
            this.id = id;
        }

        String getTipo() {
            return tipo;
        }

        String getNome() {
            return nome;
        }

        String getId() {
            return id;
        }
    }

    private static JTextArea documentLabel = new JTextArea("\n");
    private Connection connTo;
    private String sql_database_connection_to = "";
    private String sql_database_password_to = "";
    private String sql_database_user_to = "";
    private String database = "";
    private String sql_table_to = "";

    private static List<Sensor> validSensors = new ArrayList<>();

    public WriteMysql(String sql_table_to, String sql_database_connection_to, String sql_database_user_to,
            String sql_database_password_to) {
        this.sql_table_to = sql_table_to;
        this.sql_database_connection_to = sql_database_connection_to;
        this.sql_database_user_to = sql_database_user_to;
        this.sql_database_password_to = sql_database_password_to;
        String[] db_conect = sql_database_connection_to.split("/");
        this.database = db_conect[db_conect.length - 1];
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
    private String JsonToSqlInsertCommand(String json) {
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

    private String insertCommand(String json) {
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
        } catch (Exception e) {
            System.out.println("Mysql Server Origin down, unable to make the connection. " + e.getMessage());
        }
    }

    public boolean isDown() {
        return connTo == null;
        // try {
        // getSchemaSP("ObterListaSensores");
        // return false;
        // } catch (SQLException | NullPointerException e) {
        // return true;
        // }
    }

    public void close() {
        try {
            connTo.close();
        } catch (SQLException e) {
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

    public boolean CallToMySQL(String spName, BsonDocument document) throws SQLException {
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
            if ((!types.get(i - 1).equals("datetime") && value == null)
                    || (value != null && !isDouble(((BsonString) value).getValue())
                            && !types
                                    .get(i - 1).equals("datetime")))
                return false;

            stmt.setString(i, value == null ? null : ((BsonString) value).getValue());
        }

        // Execute the stored procedure
        stmt.execute();
        return true;
    }

    public boolean isSensorValid(String spName, BsonDocument document)
            throws SQLException {
        if (document.get("Sensor") == null) {
            // document.put("Sensor", new BsonString("Not Defined"));
            return false;
        }
        String idSensor = getIdOfSensor("Temperatura", ((BsonString) document.get("Sensor")).getValue());
        if (idSensor == null) {
            updateSensors(spName);
            idSensor = getIdOfSensor("Temperatura", ((BsonString) document.get("Sensor")).getValue());
        }

        if (idSensor != null) {
            document.put("Sensor", new BsonString(idSensor));
            return true;
        }

        // document.put("Sensor", new BsonString("Not Defined"));
        return false;

    }

    public boolean CallInsertWrongValues(String tipoMedicao, String tipoDado, BsonDocument document)
            throws SQLException {
        CallableStatement stmt = connTo.prepareCall("{call InserirNaoConformes(?,?,?)}");
        document.remove("_id");
        stmt.setString(1, document.toJson());
        stmt.setString(2, tipoMedicao);
        stmt.setString(3, tipoDado);
        stmt.execute();
        return true;
    }

    private void updateSensors(String spName) throws SQLException {
        CallableStatement stmt = connTo.prepareCall("{call " + spName + "()}");
        stmt.execute();
        validSensors = new ArrayList<>();
        ResultSet resultSet = stmt.getResultSet();
        while (resultSet.next())
            validSensors.add(new Sensor(resultSet.getString("Designacao"), resultSet.getString("Nome"),
                    resultSet.getString("IDSensor")));

    }

    private String getIdOfSensor(String tipoSensor, String nomeSensor) {
        for (Sensor sensor : validSensors)
            if (sensor.tipo.equals(tipoSensor) && sensor.nome.equals(nomeSensor))
                return sensor.id;

        return null;
    }

    public boolean isDouble(String num) {
        try {
            Double.parseDouble(num);
        } catch (NumberFormatException e) {
            return false;
        }
        return true;
    }

    public boolean isMovementValid(BsonDocument document) throws SQLException {
        String salaA = document.get("SalaOrigem") == null ? null : ((BsonString) document.get("SalaOrigem")).getValue();
        String salaB = document.get("SalaDestino") == null ? null
                : ((BsonString) document.get("SalaDestino")).getValue();
        if (salaA == null || salaB == null)
            return false;
        Statement stmt = connTo.createStatement();
        ResultSet rs = stmt
                .executeQuery(
                        "SELECT COUNT(*) FROM corredor WHERE salaa =" + Integer.parseInt(
                                salaA) + " AND salab =" + Integer.parseInt(salaB) + ";");
        // ResultSet rs = stmt
        // .executeQuery(
        // "SELECT COUNT(*) FROM corredor WHERE salaa = 1 AND salab = 2");
        if (rs.next())
            return rs.getInt("COUNT(*)") != 0;

        return false;
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