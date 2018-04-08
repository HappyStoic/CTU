package student;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.LinkedList;

public class CSPSolver {

    private Data data;
    private ArrayList<Character[][]> results = new ArrayList<>(); // All found results
    private CSPDomainFactory domainFactory;

    // Indicates if I am putting domain horizontally or vertically to result
    private Boolean doingRow = false;

    private ArrayList<LinkedList<Character[]>> allRowsDomains; // Calculated by domainFactory
    private ArrayList<LinkedList<Character[]>> allColumnsDomains; // Calculated by domainFactory
    private Boolean[] filledRows;
    private Boolean[] filledColumns;

    private Boolean doAble; // Variable for forward checking to tell whether a solution can still be found

    CSPSolver(Data d){
        data = d;
        domainFactory = new CSPDomainFactory(data);
    }


    // Method finds idx of row/column, that has the smallest domain size (is most constrained) and sets global
    // variable 'doingRow' appropriately
    private int getNextAssign(){
        int tmp = Integer.MAX_VALUE;
        int idx = -1;
        doingRow = true;
        for(int i = 0; i < data.getRows(); i++){
            LinkedList<Character[]> rowDomains = allRowsDomains.get(i);
            if(!filledRows[i] && rowDomains.size() < tmp){
                tmp = rowDomains.size();
                idx = i;
            }
        }
        for(int i = 0; i < data.getColumns(); i++){
            LinkedList<Character[]> columnDomains = allColumnsDomains.get(i);
            if(!filledColumns[i] && columnDomains.size() < tmp){
                tmp = columnDomains.size();
                idx = i;
                doingRow = false;
            }
        }
        return idx;
    }


    private ArrayList<LinkedList<Character[]>> forwardChecking(int idx, Character[] inputDomain){
        int len = doingRow ? data.getColumns() : data.getRows();
        ArrayList<LinkedList<Character[]>> removed = new ArrayList<>(len);

        for(int i = 0; i < len; i++) removed.add(i, new LinkedList<>());

        for(int i = 0; i < len; i++) {
            if((doingRow && filledColumns[i]) || (!doingRow && filledRows[i])) continue;

            LinkedList<Character[]> curDomains = doingRow ? allColumnsDomains.get(i) : allRowsDomains.get(i);

            Iterator<Character[]> iter = curDomains.iterator();
            while (iter.hasNext()) {
                Character[] curDomain = iter.next();

                if (!curDomain[idx].equals(inputDomain[i])) {
                    removed.get(i).add(curDomain);
                    iter.remove();
                }
            }
            if(curDomains.isEmpty()){
                doAble = false;
                break;
            }
        }
        return removed;

    }

    // Recursive method implementing csp algorithm
    private void cspSolve(Character[][] curResult, int depth){

        // All rows and columns are filled. We found a new result.
        if(depth == data.getRows() + data.getColumns()) {
            results.add(defeinsiveCopy2D(curResult));
            return;
        }
        boolean doingRowBackup = doingRow;
        int idx = getNextAssign(); //Sets direction to global variable 'doingRow' and returns current idx to handle

        LinkedList<Character[]> curDomains = doingRow? allRowsDomains.get(idx) : allColumnsDomains.get(idx);

        Character[] backupOfResult = defeinsiveCopy1D(idx, curResult);
        if(doingRow) filledRows[idx] = true;
        else filledColumns[idx] = true;


        for(int k = 0; k < curDomains.size(); k++){
            Character[] domain = curDomains.get(k);

            doAble = true; // First we assume that solution is doable. Forward checking might change that.

            putDomain(curResult, idx, domain);

            ArrayList<LinkedList<Character[]>> removedDomains = forwardChecking(idx, domain);
            if(doAble) cspSolve(curResult, depth+1);

            // Putting back the domains we removed in forward checking, so we do not corrupt the data.
            for(int i = 0; i < (doingRow ? data.getColumns() : data.getRows()); i++){
                for(Character[] removedDomain : removedDomains.get(i)){
                    if(doingRow) allColumnsDomains.get(i).add(removedDomain);
                    else allRowsDomains.get(i).add(removedDomain);
                }
            }
        }

        // Setting original properties, so we do not corrupt recursive data
        if(doingRow) filledRows[idx] = false;
        else filledColumns[idx] = false;
        putDomain(curResult, idx, backupOfResult);
        doingRow = doingRowBackup;
    }

    // Method copies one row/column (depending on global variable "doingRow") from result on idx (argument) position
    private Character[] defeinsiveCopy1D(int idx, Character[][] toCopy){
        Character[] newOne;
        if(doingRow){
            newOne = new Character[data.getColumns()];
            System.arraycopy(toCopy[idx], 0, newOne, 0, data.getColumns());
        } else {
            newOne = new Character[data.getRows()];
            for(int i = 0; i < data.getRows(); i++) newOne[i] = toCopy[i][idx];
        }
        return newOne;
    }

    private Character[][] defeinsiveCopy2D(Character[][] result){
        Character[][] newOne = Arrays.copyOf(result, result.length);
        for(int i = 0; i < result.length; i++) newOne[i] = Arrays.copyOf(result[i], result[i].length);
        return newOne;
    }

    // Method puts arg domain to result matrix depending on direction set in global variable "doingRow"
    private void putDomain(Character[][] result, int curIdx, Character[] domain){
        if(doingRow) System.arraycopy(domain, 0, result[curIdx], 0, data.getColumns());
        else {
            for(int i = 0; i < data.getRows(); i++){
                result[i][curIdx] = domain[i];
            }
        }
    }

    public void solve(){

        Character[][] curResult = new Character[data.getRows()][data.getColumns()];
        allRowsDomains = domainFactory.calcAllRowsDomains();
        allColumnsDomains = domainFactory.calcAllColumnsDomains();

        // Initially there is no row/column filled in result
        filledRows = new Boolean[data.getRows()];
        filledColumns = new Boolean[data.getColumns()];
        for(int i = 0; i < data.getRows(); i++) filledRows[i] = false;
        for(int i = 0; i < data.getColumns(); i++) filledColumns[i] = false;

        cspSolve(curResult, 0);
    }

    public ArrayList<Character[][]> getResult(){
        return results;
    }
}
