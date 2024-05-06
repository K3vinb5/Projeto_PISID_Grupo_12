package insertSQL;

import insertSQL.WriteMysql;
import org.bson.BsonDocument;
import org.bson.BsonString;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedList;

public class AlertInserter {

    private int averageSampleSize = 10;

    private double average;

    private Integer currentExpId;
    private double lowerLimit;
    private double higherLimit;
    private double alertHighLimit;
    private double alertLowLimit;

    private WriteMysql sqlConnection;


    private static final int BELLOWMINIMUMALERTTYPE = 1; // Tipo de alerta enviado quando a média está abaixo do aviso
    private static final int ABOVEMAXIMUMALERTTYPE = 2; // Tipo de alerta enviado quando a média está acima do aviso
    private static final int WITHINBOUNDERIESALERTTYPE = 3; // Tipo de alerta enviado quando a média regressa a valores conformes

    private int lastType = WITHINBOUNDERIESALERTTYPE; //  3: Dentro De limites,  1/2: Acima do limite min/max Alerta
    private LinkedList<Double> measurements = new LinkedList<>();


    public AlertInserter( WriteMysql sqlConnection ){
        this.sqlConnection = sqlConnection;
    }



    public void addMeasurement(BsonDocument document, ResultSet currentExp) throws SQLException {
        double val = Double.parseDouble((((BsonString) document.get("Leitura")).getValue()));
       setLimits(currentExp);
        measurements.add(val);
        int length = measurements.size();
        double sumOfValues = average* (length-1);
        if (length > averageSampleSize){
            sumOfValues -= measurements.pollFirst();
            length--;
        }
        sumOfValues += val;
        average = sumOfValues / length;
        System.out.println("Value: " + val + " | New avg:" + average + " | Size:" + measurements.size());
        checkForAlerts(document);

    }

    private void setLimits(ResultSet currentExp) throws SQLException {
        alertHighLimit =  currentExp.getDouble("TemperaturaAvisoMaximo");
        alertLowLimit = currentExp.getDouble("TemperaturaAvisoMinimo");
        higherLimit = currentExp.getDouble("TemperaturaMaxima");
        lowerLimit = currentExp.getDouble("TemperaturaMinima");
        currentExpId = currentExp.getInt("IDExperiencia");
    }

    private void checkForAlerts(BsonDocument document) throws SQLException {
        if(average <= lowerLimit || average >= higherLimit){
            sqlConnection.alertInsert(document,true,
                    "Temperatura","Temperatura excedeu o valor " + (average >= higherLimit ? "Máximo" : "Mínimo"));
            sqlConnection.closeExp(currentExpId);
            lastType = WITHINBOUNDERIESALERTTYPE;
            return;
        }
        if (average <= alertLowLimit || average >= alertHighLimit){
            String message;
            int newType = average <= alertLowLimit ? BELLOWMINIMUMALERTTYPE : ABOVEMAXIMUMALERTTYPE;
            if(lastType == WITHINBOUNDERIESALERTTYPE)
                message = average <= alertLowLimit ? "Temperatura ultrapassou a tolerância minima!" : "Temperatura ultrapassou a tolerância máxima!" ;
            else
                message = average <= alertLowLimit ? "Temperatura continua abaixo da tolerância!" : "Temperatura continua acima da tolerância!" ;
            if (sqlConnection.alertInsert(document,true,"Temperatura"+newType,message))
                lastType = newType;
            return;
        }
        if (lastType != WITHINBOUNDERIESALERTTYPE && sqlConnection.alertInsert(document,true,"Temperatura"+WITHINBOUNDERIESALERTTYPE,"Temperatura regressou aos limites"))
                lastType = WITHINBOUNDERIESALERTTYPE;
    }



}
