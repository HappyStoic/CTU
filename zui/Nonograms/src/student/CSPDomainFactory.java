package student;


import javafx.util.Pair;

import java.util.ArrayList;
import java.util.LinkedList;

public class CSPDomainFactory {

    private final Character emptyCharacter = '_'; // Represents empty space in domain
    private Data data;


    //-------------------------------------------------------------------
    // Variables accessed from recursive method 'domainCreator'
    private LinkedList<Character[]> domainToReturn; // Found domains are stored in this linkedList
    private Character[] adjusting; // Array that is modified to find correct domains
    private ArrayList<Pair<Character, Integer>> constraints; // Proper constraints set before domainCreator is called
    //-------------------------------------------------------------------

    CSPDomainFactory(Data d){
        data = d;
    }

    // Recursively fills 'adjusting' array with all rules covered. Initially called with (0, 0, 0) arguments
    private void domainCreator(int curDepth, int curPairIdx, int alreadyLaid){

        //All positions are filled
        if(curDepth == adjusting.length) {

            // And all symbols are already put, that means I have found a valid domain
            if(curPairIdx == constraints.size()) domainToReturn.add(copyArray(adjusting));

        // All symbols are put, but not the whole array is filled (empty spaces are missing)
        } else if (curPairIdx == constraints.size()){
            adjusting[curDepth] = emptyCharacter;
            domainCreator(curDepth+1, curPairIdx, alreadyLaid);
        } else {
            Integer toLay = constraints.get(curPairIdx).getValue(); // I need to put this quantum of current symbols
            Character nextSymbol = constraints.get(curPairIdx).getKey(); // Current symbol to be put
            Character prevSymbol = curDepth == 0 ? null : adjusting[curDepth-1]; // Previous symbol put (null if depth is 0)

            boolean nextFillSpace = alreadyLaid == 0 && nextSymbol.equals(prevSymbol); // Now an empty space must be placed
            boolean nextFillSymbol = alreadyLaid < toLay && alreadyLaid != 0; // Now a symbol must be placed

            if(nextFillSpace || !nextFillSymbol){
                adjusting[curDepth] = emptyCharacter;
                domainCreator(curDepth + 1, curPairIdx, alreadyLaid);
            }

            if (nextFillSymbol || !nextFillSpace){
                adjusting[curDepth] = nextSymbol;

                // If I placed correct quantity of symbols, I need to increment 'curPairIdx' to handle new constraint
                // and set alreadyLaid to 0, because I did not put any symbol of next constraints
                if (alreadyLaid + 1 == toLay) domainCreator(curDepth + 1, curPairIdx + 1, 0);
                else domainCreator(curDepth + 1, curPairIdx, alreadyLaid + 1);
            }
        }
    }

    private LinkedList<Character[]> getDomain(int idx, boolean row){
        domainToReturn = new LinkedList<>();

        if(row) constraints = data.getRowConstraints().get(idx);
        else constraints = data.getColumnConstraints().get(idx);

        domainCreator(0, 0, 0);

        return domainToReturn;
    }

    public ArrayList<LinkedList<Character[]>> calcAllRowsDomains(){
        int rows = data.getRows();
        adjusting = new Character[data.getColumns()];
        ArrayList<LinkedList<Character[]>> allRowsDomains = new ArrayList<>(rows);
        for(int i = 0; i < rows; i++){
            allRowsDomains.add(getDomain(i, true));
        }
        return allRowsDomains;
    }

    public ArrayList<LinkedList<Character[]>> calcAllColumnsDomains(){
        int columns = data.getColumns();
        adjusting = new Character[data.getRows()];
        ArrayList<LinkedList<Character[]>> allColumnsDomains = new ArrayList<>(columns);
        for(int i = 0; i < columns; i++){
            allColumnsDomains.add(getDomain(i, false));
        }
        return allColumnsDomains;
    }

    private Character[] copyArray(Character[] toCopy){
        int len = toCopy.length;
        Character[] newOne = new Character[len];
        System.arraycopy(toCopy, 0, newOne, 0, len);
        return newOne;
    }

}