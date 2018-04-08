package student;


import javafx.util.Pair;
import java.util.ArrayList;

public class Data {


    private int rows;
    private int columns;

    private ArrayList<ArrayList<Pair<Character, Integer>>> rowConstraints;
    private ArrayList<ArrayList<Pair<Character, Integer>>> columnConstraints;

    public void addRowConstraints(ArrayList<Pair<Character, Integer>> rowConstraints) {
        this.rowConstraints.add(rowConstraints);
    }

    public void addColumnConstraints(ArrayList<Pair<Character, Integer>> columnConstraints) {
        this.columnConstraints.add(columnConstraints);
    }

    public int getRows() {
        return rows;
    }

    public int getColumns() {
        return columns;
    }

    public ArrayList<ArrayList<Pair<Character, Integer>>> getRowConstraints() {
        return rowConstraints;
    }

    public ArrayList<ArrayList<Pair<Character, Integer>>> getColumnConstraints() {
        return columnConstraints;
    }

    Data(int r, int c){
        rows = r;
        columns = c;

        rowConstraints = new ArrayList<>(r);
        columnConstraints = new ArrayList<>(c);
    }

}
