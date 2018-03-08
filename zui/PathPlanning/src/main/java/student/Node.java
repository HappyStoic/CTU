package student;

import cz.cvut.atg.zui.astar.Utils;
import eu.superhub.wp5.planner.planningstructure.GraphEdge;
import eu.superhub.wp5.planner.planningstructure.GraphNode;

/**
 * Class Node is wrapping GraphNode with its costs.
 * f(n) = g(n) + h(n)
 */
public class Node implements Comparable<Node> {

    private GraphNode curGraphNode;
    private GraphNode goalNode;

    /**
     * The shortest path from initial node to this node is along this edge
     * if null - this is the initial node
     */
    private GraphEdge edgeFromParent;

    /**
     * The shortest path from initial node to this node is through this node
     */
    private Node parentNode;

    /**
     * f(n)
     */
    private Double sumCost = Double.MAX_VALUE;

    /**
     * g(n)
     * how fast can i get from origin node to his node
     */
    protected Double fromOriginCost = Double.MAX_VALUE;

    /**
     * h(n)
     * heuristic function - Eucleidian distance from this node to goalNode divided with the biggest permitted speed
     */
    protected Double toDestCost = Double.MAX_VALUE;

    public Node(GraphNode n, GraphNode goal){
        curGraphNode = n;
        goalNode = goal;
        calculateTimeOnEuklidDistance();
    }

    public void calculateAndSetCost(Double fromOriginToParentCost){
        if(edgeFromParent == null){
            fromOriginCost = 0D;
            sumCost = toDestCost;
        } else {
            fromOriginCost = fromOriginToParentCost + ((edgeFromParent.getLengthInMetres()/1000D/edgeFromParent.getAllowedMaxSpeedInKmph()));
            sumCost = fromOriginCost + toDestCost;
        }
    }



    public Double calculateCost(GraphEdge newEdge, Double newfromOriginToParentCost){
        if(newEdge == null){
            return toDestCost;
        } else {
            return toDestCost + newfromOriginToParentCost + ((newEdge.getLengthInMetres()/1000D/newEdge.getAllowedMaxSpeedInKmph()));
        }
    }


    private void calculateTimeOnEuklidDistance(){
        toDestCost = Utils.distanceInKM(curGraphNode, goalNode)/Planner.MAX_SPEED;
    }

    public void setFromOriginCost(Double fromOriginToParentCost ) {
        this.fromOriginCost = fromOriginToParentCost + ((edgeFromParent.getLengthInMetres()/1000D/edgeFromParent.getAllowedMaxSpeedInKmph()));
    }

    @Override
    public int compareTo(Node o) {
//        double res = this.getSumCost() - o.getSumCost();
//        boolean res = this.getSumCost() < o.getSumCost();
        if (o.getSumCost() < this.getSumCost()) return 1;
        if (this.getSumCost() < o.getSumCost()) return -1;
        return 0;
    }

    public GraphEdge getEdgeFromParent(){
        return edgeFromParent;
    }
    public Node getParentNode() {
        return parentNode;
    }

    public void setEdgeFromParent(GraphEdge edgeFromParent) {
        this.edgeFromParent = edgeFromParent;
    }
    public void setParentNode(Node parentNode) {
        this.parentNode = parentNode;
    }
    public void setSumCost(Double sum){
        this.sumCost = sum;
    }

    public GraphNode getGraphNode(){
        return curGraphNode;
    }

    public Double getSumCost(){
        return sumCost;
    }
}