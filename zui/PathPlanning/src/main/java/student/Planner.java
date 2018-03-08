package student;

import cz.cvut.atg.zui.astar.AbstractOpenList;
import cz.cvut.atg.zui.astar.PlannerInterface;
import cz.cvut.atg.zui.astar.RoadGraph;
import eu.superhub.wp5.planner.planningstructure.GraphEdge;
import eu.superhub.wp5.planner.planningstructure.GraphNode;

import java.util.*;

/**
 * Author: Martin Řepa
 * Description in PlannerInterface
 */
public class Planner implements PlannerInterface {

    public static Double MAX_SPEED = 120D; // Max permitted speed parsed previously from all edges

    private OpenList openList = new OpenList();
    private HashSet<GraphNode> closedList = new HashSet<>();


    @Override
    public List<GraphEdge> plan(RoadGraph graph, GraphNode origin, GraphNode destination) {

        long goalId = destination.getId();

        Node startNode = new Node(origin, destination);
        startNode.setParentNode(null);
        startNode.setEdgeFromParent(null);
        startNode.calculateAndSetCost(0D);
        openList.add(startNode);

        while(!openList.isEmpty()){

            Node currentNode = openList.getWithLowestCost();
            GraphNode currGraphNode = currentNode.getGraphNode();


            if(currentNode.getGraphNode().getId() == goalId){ // HEUREKA
                return getFinalPath(currentNode);
            }


            closedList.add(currGraphNode);


            List<GraphEdge> outcoming = graph.getNodeOutcomingEdges(currGraphNode.getId());
            if(outcoming == null) continue; //To avoid nullptr exception

            for(GraphEdge edge : outcoming){

                long to = edge.getToNodeId();
                GraphNode childGraphNode = graph.getNodeByNodeId(to);

                if(closedList.contains(childGraphNode)) continue; //No need to go back to already closed node

                Node alreadyCreated = openList.get(childGraphNode); // if null, no such element is in open list
                if(alreadyCreated != null){
                    Double newSum = alreadyCreated.calculateCost(edge, currentNode.fromOriginCost);

                    if(newSum < alreadyCreated.getSumCost()){ // The way found to this element is actually better
                        alreadyCreated.setParentNode(currentNode);
                        alreadyCreated.setEdgeFromParent(edge);
                        alreadyCreated.setFromOriginCost(currentNode.fromOriginCost);
                        alreadyCreated.setSumCost(newSum);

                        openList.remove(alreadyCreated); //I Need to remove and again reAdd the element so I keep the queue sorted
                        openList.add(alreadyCreated);

                    }
                    continue;
                }

                // Let's create new node
                Node newNode = new Node(childGraphNode, destination);
                newNode.setParentNode(currentNode);
                newNode.setEdgeFromParent(edge);
                newNode.calculateAndSetCost(currentNode.fromOriginCost);
                openList.add(newNode);

            }
        }

        return null;
    }

    /**
     *
     * @param currNode desired goalNode in path
     * @return final path in List
     */
    private List<GraphEdge> getFinalPath(Node currNode){
        Stack<GraphEdge> solution = new Stack<>();
        GraphEdge edge = currNode.getEdgeFromParent();

        while(edge != null){
            solution.push(edge);
            currNode = currNode.getParentNode();
            edge = currNode.getEdgeFromParent();
        }

        ArrayList<GraphEdge> toReturn = new ArrayList<>();
        while(!solution.empty()){
            toReturn.add(solution.pop());
        }
        return toReturn;
    }

    @Override
    public AbstractOpenList getOpenList() {
        return openList;
    }
}