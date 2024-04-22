import java.util.ArrayList;
import java.util.LinkedList;
import java.util.Queue;

public class OutlierDetector {

    private static final int OUTLIERDETECTORSIZE = 100;
    private ArrayList<Double> orderedValues = new ArrayList<>();
    private Queue<Double> lastValues = new LinkedList<>();

    /**
     * Tests if value from parameter is an Outlier in the recent data set in orderedValues
     *
     * @param value value to test for outlier
     * @return true if the value is an Outlier or false otherwise
     */
    public boolean checkOutlier(double value){
        if(orderedValues.size() == OUTLIERDETECTORSIZE){
            orderedValues.remove(lastValues.poll());
        }
        lastValues.add(value); //Add new value to Queue
        orderedValues.add(value); //Add new value to sortedArray
        insertionSort(orderedValues); //Sort new value using Insertion Sort
        return isIQROutlier(value); //Verify if value is outlier using IQR
    }

    private boolean isIQROutlier(double value) {

        // Calculate the first and third quartiles
        double q1 = quartile(orderedValues, 0.25);
        double q3 = quartile(orderedValues, 0.75);

        // Calculate the interquartile range (IQR)
        double iqr = q3 - q1;
        // Calculate the lower and upper bounds for outliers
        double lowerBound = q1 - 1.5 * iqr;
        double upperBound = q3 + 1.5 * iqr;

        return (value < lowerBound || value > upperBound);
    }

    private static double quartile(ArrayList<Double> values, double quantile) {
        int index = (int) Math.ceil(quantile * (values.size() + 1)) - 1;
        if (index < 0) {
            return values.get(0);
        }
        if (index >= values.size()) {
            return values.get(values.size() - 1);
        }
        double fraction = index - Math.floor(index);
        if (fraction == 0) {
            return values.get(index);
        }
        return values.get(index) + fraction * (values.get(index + 1) - values.get(index));
    }

    public static void insertionSort(ArrayList<Double> arr) {
        int n = arr.size();
        for (int i = 1; i < n; ++i) {
            double key = arr.get(i);
            int j = i - 1;
            for (;j >= 0 && arr.get(j) > key;j--) {
                arr.set(j + 1, arr.get(j));
            }
            arr.set(j + 1, key);
        }
    }

    public static void main(String[] args) {
        OutlierDetector od = new OutlierDetector();
        int counter = 0;
        for (int i = 0 ; i < 1000 ; i++){
            double val = i % 100 == 0 ? Math.random()*100-50 : Math.random()*20;
            if (od.checkOutlier(val)){
                counter++;
                System.out.println("Outlier Found!! " + counter + ":- " + val  );
            }
        }
    }
}
