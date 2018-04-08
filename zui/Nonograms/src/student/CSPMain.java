package student;

import java.util.ArrayList;

/**
 * Author: Martin Repa, King Of The North
 * Date: 8.5.2018
 *
 * <p>
 * <b>CSP FORMALISATION:</b>
 * <li>Variable - every row and every column is a variable</li>
 * <li>Domain - every possible placement of symbols fulfilling all nonogram rules and all constraints related to given row/column</li>
 * <li>Constraint - every column domain which is about to be placed to result matrix on Ith column must have the same symbol on Jth position as
 *              matrix[J][I] (if the spot is currently filled with some char)
 *              and alternatively every row domain which is about to be put placed on Ith row must have the same symbol on Jth position
 *              as matrix[I][J] (if the spot is currently filled with some char)</li>
 *</p>
 *
 * <p>
 *     <li>CSP algorithm including forward checking is implemented. Exact implementation is everywhere properly commented</li>
 *     <li>Java class CSPDomainFactory is creating domains for all rows/columns. Again the src is commented for further details</li>
 * </p>
 *
 */

public class CSPMain {



    public static void main(String[] args) {

        Data data = Reader.readData();
        if(data == null) return;

        CSPSolver solver = new CSPSolver(data);
        solver.solve();

        printResults(solver.getResult());
    }

    private static void printResults(ArrayList<Character[][]> results ){
        if(results.size() == 0) System.out.println("null");
        else {
            for (Character[][] result : results) {
                for (Character[] column : result) {
                    for (Character rowChar : column) {
                        System.out.print(rowChar);
                    }
                    System.out.println();
                }
                System.out.println();
            }
        }
    }

}
