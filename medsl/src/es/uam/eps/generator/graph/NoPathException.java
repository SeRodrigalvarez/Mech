package es.uam.eps.generator.graph;

import es.uam.eps.medsl.State;

public class NoPathException extends Exception {

	private static final long serialVersionUID = -7910551625843960156L;
	
	private State state;
	
	public NoPathException () {
		super();
	}
	
	public NoPathException (State state) {
		super();
		this.state=state;
	}
	
	public State getStateException () {
		return this.state;
	}

}
