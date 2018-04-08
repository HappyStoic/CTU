package student;

import javafx.util.Pair;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;

public class Reader {

    public static Data readData(){
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        try {

            String[] line = reader.readLine().split(",");
            int rows = Integer.parseInt(line[0]);
            int columns = Integer.parseInt(line[1]);

            Data data = new Data(rows, columns);


            for(int i = 0; i < rows; i++){
                line = reader.readLine().split(",");
                int len = line.length;
                ArrayList<Pair<Character, Integer>> rowConstraints = new ArrayList<>(len/2);
                for(int j = 0; j < len; j+=2){
                    rowConstraints.add(new Pair<>(line[j].charAt(0), Integer.parseInt(line[j + 1])));
                }
                data.addRowConstraints(rowConstraints);
            }

            for(int i = 0; i < columns; i++){
                line = reader.readLine().split(",");
                int len = line.length;
                ArrayList<Pair<Character, Integer>> columnConstraints = new ArrayList<>(len/2);
                for(int j = 0; j < len; j+=2){
                    columnConstraints.add(new Pair<>(line[j].charAt(0), Integer.parseInt(line[j + 1])));
                }
                data.addColumnConstraints(columnConstraints);
            }
            return data;


        } catch (IOException exc){
            exc.printStackTrace();
            return null;
        }

    }


}
