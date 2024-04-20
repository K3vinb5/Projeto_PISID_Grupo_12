package cloudToMongo;

import java.util.concurrent.atomic.AtomicInteger;

public class CollectionPersonalized {
    private AtomicInteger autoIncrement;
    private String collectionName;

    CollectionPersonalized(String collectionName) {
        this.collectionName = collectionName;
    }

    void setInitialValue(int initalValue) {
        autoIncrement = new AtomicInteger(initalValue);
    }

    public int getAndIncrement() {
        return autoIncrement.getAndIncrement();
    }

    public String getCollectionName() {
        return collectionName;
    }
}
