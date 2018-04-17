package cz.cvut.student;

import cz.cvut.fel.aic.zui.gobblet.Gobblet;
import cz.cvut.fel.aic.zui.gobblet.algorithm.Algorithm;
import cz.cvut.fel.aic.zui.gobblet.environment.Board;
import cz.cvut.fel.aic.zui.gobblet.environment.Move;
import javafx.util.Pair;

import java.util.ArrayList;
import java.util.HashMap;

public class AlphaBeta extends Algorithm {

    private final int MAX_PLAYER = 0;

    // Caching <Pair<Pair<game, pair<alpha, beta>>, depth>, value> These values defines the state
    private HashMap<Pair<Pair<Board, Pair<Integer, Integer>>, Integer>, Integer> maxCache = new HashMap<>();
    private HashMap<Pair<Pair<Board, Pair<Integer, Integer>>, Integer>, Integer> minCache = new HashMap<>();


    private int max(int a, int b){ return a < b? b : a; }
    private int min(int a, int b){ return a < b? a : b; }

    private ArrayList<Board> getSortedSucBoards(Board game, ArrayList<Move> successors, int player){
        ArrayList<Board> subBoards = new ArrayList<>(successors.size());
        successors.forEach( t -> {Board tmp = new Board(game); tmp.makeMove(t); subBoards.add(tmp);});

        ArrayList<Pair<Integer, Integer>> boardValues = new ArrayList<>(successors.size());
        for(int i = 0; i < subBoards.size(); i++)
            boardValues.add(new Pair<>(i, subBoards.get(i).evaluateBoard()));


        boardValues.sort((o1, o2) -> {
            if (o1.getValue() > o2.getValue()) return player == MAX_PLAYER ? -1 : 1;
            if (o1.getValue() < o2.getValue()) return player == MAX_PLAYER ? 1 : -1;
            else return 0;
        });

        ArrayList<Board> toReturn = new ArrayList<>(successors.size());
        boardValues.forEach(t-> toReturn.add(subBoards.get(t.getKey())));
        return toReturn;
    }

    @Override
    protected int runImplementation(Board game, int depth, int player, int alpha, int beta) {
        int alphaBackup = alpha, betaBackup = beta;

        if(depth == 0 || game.isTerminate(player) >= 0) return game.evaluateBoard(); // Game ends
        ArrayList<Move> successors = game.generatePossibleMoves(player);

        // Check if we already have the result
        Pair<Pair<Board, Pair<Integer, Integer>>, Integer> check  = new Pair<>(new Pair<>(game, new Pair<>(alpha, beta)), depth);
        if (player == MAX_PLAYER && maxCache.containsKey(check)) return maxCache.get(check);
        else if (player != MAX_PLAYER && minCache.containsKey(check)) return minCache.get(check);


        ArrayList<Board> succBoards = getSortedSucBoards(game, successors, player);

        if(player == MAX_PLAYER){
            boolean first = true;
            int tmpB = beta;

            if(depth == 1) return succBoards.get(0).evaluateBoard();
            for(Board sucBoard : succBoards){
                int tmpA = run(sucBoard, depth-1, Gobblet.switchPlayer(player), alpha, tmpB);
                if(alpha < tmpA && !first)
                    tmpA = run(sucBoard, depth-1, Gobblet.switchPlayer(player), alpha, beta);


                alpha = max(alpha, tmpA);
                if(beta <= alpha) break;
                tmpB = alpha + 1;
                first = false;
            }
            Pair<Pair<Board, Pair<Integer, Integer>>, Integer> toPut = new Pair<>(new Pair<>(game, new Pair<>(alphaBackup, betaBackup)), depth);
            maxCache.put(toPut, alpha); // Let's cache cur result

            return alpha;
        } else {
            boolean first = true;
            int tmpA = alpha;

            if(depth == 1) return succBoards.get(0).evaluateBoard();
            for(Board sucBoard : succBoards){
                int tmpB = run(sucBoard, depth-1, Gobblet.switchPlayer(player), tmpA, beta);
                if(beta > tmpB && !first)
                    tmpB = run(sucBoard, depth - 1, Gobblet.switchPlayer(player), alpha, beta);


                beta = min(beta, tmpB);
                if(beta <= alpha) break;
                tmpA = beta - 1;
                first = false;
            }

            Pair<Pair<Board, Pair<Integer, Integer>>, Integer> toPut = new Pair<>(new Pair<>(game, new Pair<>(alphaBackup, betaBackup)), depth);
            minCache.put(toPut, beta); // Let's cache cur result

            return beta;
        }
    }
}
