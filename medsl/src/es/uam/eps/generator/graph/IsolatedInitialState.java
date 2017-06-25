package es.uam.eps.generator.graph;

import es.uam.eps.medsl.InitialState;

public class IsolatedInitialState extends Exception {

	private static final long serialVersionUID = 2708470793288505872L;
	
	private InitialState state;
	
	public IsolatedInitialState() {
		super();
	}
	
	public IsolatedInitialState(InitialState state) {
		super();
		this.state=state;
	}
	
	public InitialState getStateException () {
		return this.state;
	}
	
}
