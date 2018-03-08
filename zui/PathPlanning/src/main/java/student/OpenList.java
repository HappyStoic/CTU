package student;

import cz.cvut.atg.zui.astar.AbstractOpenList;
import eu.superhub.wp5.planner.planningstructure.GraphNode;

import java.util.*;


/**
 * Class representing list with possible next moves. Nodes in Queue are sorted with
 * Node::sumCost, therefore only head is returned when new node is needed.
 */
public class OpenList extends AbstractOpenList {


    private Queue<Node> fringe = new PriorityQueue<>();

    @Override
    protected boolean addItem(Object item) {
        return fringe.add((Node) item);
    }

    protected boolean isEmpty(){
        return fringe.isEmpty();
    }

    protected Node getWithLowestCost(){
        return fringe.poll();

    }

    protected void remove(Node node){
        fringe.remove(node);
    }



    protected Node get(GraphNode n){
        return fringe.stream().filter(t-> t.getGraphNode().equals(n)).findAny().orElse(null);
    }
}
