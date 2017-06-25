package es.uam.eps.generator.graph

import es.uam.eps.medsl.State
import java.util.List
import es.uam.eps.medsl.Transition
import es.uam.eps.medsl.Domainmodel
import java.util.Set
import java.util.Map
import java.util.LinkedList
import java.util.Queue
import java.util.ArrayList
import java.util.Random
import java.util.HashSet
import java.util.HashMap
import es.uam.eps.medsl.AbstractState
import es.uam.eps.medsl.InitialState

class Graph {
	
	private Domainmodel dm;
	
	private List<List<Transition>> nodeCoverage;
	private List<List<Transition>> edgeCoverage;
	
	/* TODO: Gestionar los grafos de un nodo */
	/* TODO: Gestionar grafo con callejon sin salida en ciclo infinito*/
	public new (Domainmodel dm) throws NoPathException, IsolatedInitialState {
		
		this.dm=dm;
		
		var int flag;
		
		for (AbstractState i : dm.initial) {
			if (i.edges.empty) {
				throw new IsolatedInitialState (i as InitialState);
			}
		}
		
		for (State e : dm.states) {
			flag=0;
			for (InitialState i : dm.initial) {
				if (BFS (i, e)!=null) {
					flag=1;
				}
			}
			if (flag==0) {
				throw new NoPathException (e);
			}
		}
	}
	
	public def List<Transition> BFS (InitialState initialNode, State objectiveNode) {
		
		var Set<AbstractState> visited;
		var Map<AbstractState, Integer> distance;
		var Map<AbstractState, AbstractState> father;
		var Queue<AbstractState> queue;
		// Mapa de ayuda para obtener el path de edges al nodo objetivo
		var Map<AbstractState, Transition> back;
		
		var LinkedList<Transition> path;
		
		var AbstractState node
		var AbstractState adjacent;
			
		visited=new HashSet<AbstractState>();
		distance=new HashMap<AbstractState, Integer>();
		father=new HashMap<AbstractState, AbstractState>();
		back=new HashMap<AbstractState, Transition>();
		
		visited.add(initialNode);
		distance.put(initialNode, 0);
		father.put(initialNode, null);
		
		queue=new LinkedList<AbstractState>();
		
		queue.offer(initialNode);
		
		while (!queue.isEmpty()) {
			node = queue.poll();
			
			adjacent=null
			
			for (Transition edge : node.getEdges()) {
				adjacent=edge.state2;
				
				if (!visited.contains(adjacent)) {
					visited.add(adjacent);
					distance.put(adjacent, distance.get(node)+1);
					father.put(adjacent, node);
					back.put(adjacent, edge);
					queue.offer(adjacent);
				}
			}
			
			if (node==objectiveNode) {
				path=new LinkedList<Transition>();
				
				while (back.get(node)!=null) {
					path.addFirst(back.get(node));
					node=father.get(node);
				}
				
				return path;
			}
		}
		
		return null;
	}
	
	public def List<Transition> RandomPath (AbstractState objectiveNode) {
		
		if (objectiveNode instanceof InitialState) {
			return new ArrayList<Transition>();
		}
		
		var List<Transition> returnPath;
		
		var Random rand = new Random();
		
		var InitialState node;
		
		var List<InitialState> startNodesCopy = new ArrayList<InitialState>();
		startNodesCopy.addAll(this.dm.initial);
		
		var int copyLength = startNodesCopy.size();
		
		for (var int i = 0; i<copyLength; i++) {
			
			node=startNodesCopy.get(rand.nextInt(startNodesCopy.size()));
			
			startNodesCopy.remove(node);
			
			if ((returnPath=BFS(node, objectiveNode as State))!=null) {
				return returnPath;
			}
		}
		
		return null;
		
	}
	
	public def nodeCoverage (int loopIterationsArg) {
		
		var State node;
		var Transition edge;
		
		var List<Transition> tempEdges;
		
		var List<Transition> path;
		var List<AbstractState> nodePath;
		var List<State> nonVisitedNodes = new ArrayList<State>();
		nonVisitedNodes.addAll(dm.states);
		
		this.nodeCoverage=new ArrayList<List<Transition>>();
		
		var Random rand = new Random();
		
		var int i;
		var int loopIterations;
		var int loopStart;
		var boolean flag;
		var boolean loopFlag;
		
		if (loopIterationsArg<0) {
			loopIterations=0;
		} else {
			loopIterations=loopIterationsArg;
		}
		
		while (!nonVisitedNodes.isEmpty()) {
			
			edge=null;
			
			loopFlag=false;
			
			node=nonVisitedNodes.get(rand.nextInt(nonVisitedNodes.size()));
			
			nonVisitedNodes.remove(node);
			
			path=this.RandomPath(node);
			
			nodePath = new ArrayList<AbstractState>();
			
			for (Transition e:path) {
				nonVisitedNodes.remove(e.state1);
				nodePath.add(e.state1);
			}
			
			nodePath.add(node);
			
			tempEdges=node.getEdges();
			
			if (tempEdges.size()!=0) {
				
				loopFlag=true;
				
				edge=tempEdges.get(rand.nextInt(tempEdges.size()));
				
				node=edge.state2;
			
				while (!nodePath.contains(node)) {
					
					nodePath.add(node);
					
					nonVisitedNodes.remove(node);
					
					path.add(edge);
					
					tempEdges=node.getEdges();
					
					if (tempEdges.size()==0) {
						loopFlag=false;
					} else {
						edge=tempEdges.get(rand.nextInt(tempEdges.size()));
						
						node=edge.state2;
					}
				}
			}
			
			if (loopFlag && loopIterations > 0) {
				
				flag = true;
				
				path.add(edge);
				
				for (i=0; i<path.size() && flag; i++) {
					if (nodePath.get(i).equals(node)) {
						flag=false;
					}
				}
				
				loopStart=i-1;
				
				tempEdges=new ArrayList<Transition>();
				
				for (i=loopStart; i<path.size(); i++) {
					tempEdges.add(path.get(i));
				}
				
				for (i=0; i<loopIterations; i++) {
					path.addAll(tempEdges);
				}
				
			}	
			
			nodeCoverage.add(path);
		}
	}
	
	public def void edgeCoverage (int loopIterationsArg) {
		
		var State node;
		var Transition edge;
		
		var List<Transition> tempEdges;
		
		var List<Transition> path;
		var List<AbstractState> nodePath;
		var List<Transition> nonVisitedEdges = new ArrayList<Transition>();
		nonVisitedEdges.addAll(dm.transitions);
		
		edgeCoverage=new ArrayList<List<Transition>>();
		
		var Random rand = new Random();
		
		var int i;
		var int loopIterations;
		var int loopStart;
		var boolean loopFlag;
		var boolean flag;
		
		if (loopIterationsArg<0) {
			loopIterations=0;
		} else {
			loopIterations=loopIterationsArg;
		}
		
		while (!nonVisitedEdges.isEmpty()) {
			
			loopFlag=true;
			
			edge=nonVisitedEdges.get(rand.nextInt(nonVisitedEdges.size()));
			
			nonVisitedEdges.remove(edge);
			
			path=this.RandomPath(edge.state1);
			
			nonVisitedEdges.removeAll(path);
			
			path.add(edge);
			
			nodePath = new ArrayList<AbstractState>();
			
			for (Transition e:path) {
				nodePath.add(e.state1);
			}
			
			node=edge.state2;
			
			while (!nodePath.contains(node) && loopFlag) {
				
				nodePath.add(node);
				
				tempEdges=node.getEdges();
				
				if (tempEdges.size()==0) {
					loopFlag=false;
				} else {
				
					edge=tempEdges.get(rand.nextInt(tempEdges.size()));
					
					node=edge.state2;
					
					nonVisitedEdges.remove(edge);
					
					path.add(edge);
				}
			}
			
			if (loopFlag && loopIterations > 0) {
				
				flag=true;
				
				for (i=0; i<path.size() && flag; i++) {
					if (nodePath.get(i).equals(node)) {
						flag=false;
					}
				}
				
				loopStart=i-1;
				
				tempEdges=new ArrayList<Transition>();
				
				for (i=loopStart; i<path.size(); i++) {
					tempEdges.add(path.get(i));
				}
				
				for (i=0; i<loopIterations; i++) {
					path.addAll(tempEdges);
				}
				
			}
			edgeCoverage.add(path);
		}
	}
	
	public def List<List<Transition>> getNodeCoverage() {
		return this.nodeCoverage;
	}
	
	public def List<List<Transition>> getEdgeCoverage() {
		return this.edgeCoverage;
	}
	
	def List<Transition> getEdges (AbstractState node) {
		
		var List<Transition> edges = new ArrayList<Transition>();
		
		for (Transition e : this.dm.transitions) {
			if (e.state1 == node) {
				edges.add(e);
			}
		}
		
		return edges;
	}
}