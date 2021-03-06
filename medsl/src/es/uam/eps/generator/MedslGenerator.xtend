/*
 * generated by Xtext 2.10.0
 */
package es.uam.eps.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import es.uam.eps.medsl.Domainmodel
import javax.inject.Inject
import org.eclipse.xtext.naming.IQualifiedNameProvider
import es.uam.eps.medsl.Transition
import es.uam.eps.medsl.Assert
import es.uam.eps.medsl.Command
import org.eclipse.emf.ecore.EObject
import es.uam.eps.generator.graph.Graph
import es.uam.eps.medsl.InitialState

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class MedslGenerator extends AbstractGenerator {
	
	var int counter;
	var Domainmodel dm;
	
	def void iniCounter() {
		counter=0;
	}
	
	def void incCounter() {
		counter++;
	}
	
	def int getCounter() {
		return counter;
	}
	
	@Inject extension IQualifiedNameProvider
	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		
        this.dm = resource.allContents.findFirst[EObject e | e instanceof Domainmodel] as Domainmodel;
        
        fsa.generateFile(
				dm.package.replace('.','/')+"/"+ dm.fullyQualifiedName + "Test.java",
				compile)
        
	}
	
	def compile() '''
	    package «dm.package»;
	    
	    «FOR i:dm.imports»
	    	import «i.imp»;
		«ENDFOR»

	    import static org.junit.Assert.assertEquals;
	    
	    import org.junit.Test;
	    
	    public class «dm.fullyQualifiedName»Test {
	    	«generateTests»
	    }
	'''
	
	// TODO: Gestionar Excepciones
	def generateTests () {
		
		var Graph graph = new Graph (dm);
		
		var int count = Integer.parseInt(dm.count);
		var String strategy = dm.strategy;
		
		if (strategy.compareTo('state')==0) {
			generateNodeCoverageTests(graph, count);
		} else if (strategy.compareTo('transition')==0) {
			generateEdgeCoverageTests(graph, count);
		} else { //both
			generateNodeCoverageTests(graph, count) + "" + generateEdgeCoverageTests(graph, count);
		}
	}
	
	def generateNodeCoverageTests(Graph graph, int loopCount) '''
		«graph.nodeCoverage(loopCount)»
		«iniCounter»
		«FOR l : graph.nodeCoverage»
			@Test
			public void nodePath«getCounter.toString»() {
				«compile (l.get(0).state1 as InitialState)»
				«FOR t : l»
					«t.compile»
				«ENDFOR»
			}
			«incCounter»
		«ENDFOR»
	'''
	
	def generateEdgeCoverageTests(Graph graph, int loopCount) '''
		«graph.edgeCoverage(loopCount)»
		«iniCounter»
		«FOR l : graph.edgeCoverage»
			@Test
			public void edgePath«getCounter.toString»() {
				«compile (l.get(0).state1 as InitialState)»
				«FOR t : l»
					«t.compile»
				«ENDFOR»
			}
			«incCounter»
		«ENDFOR»
	'''
	
	def compile (InitialState s) '''
		«IF s.constructor==null»
			«dm.fullyQualifiedName» var«getCounter.toString» = new «dm.fullyQualifiedName»();
		«ELSE»
			«dm.fullyQualifiedName» var«getCounter.toString» = new «s.constructor»;
		«ENDIF»
	'''
	
	def compile (Transition t) '''
		«IF t.op != null»
			if (!(«t.guard1.compile» «t.op» «t.guard2.compile»)) {
				return;
			}
		«ENDIF»
		var«getCounter.toString».«t.command.compile»
		«FOR e:t.assert»
			«e.compile»
		«ENDFOR»
	'''
	
	def compile (Command m) '''
		«m.proc»;
	'''
	
	def compile (Assert a) '''
		«a.type» («a.assert1.compile» , «a.assert2.compile»);
	'''
	
	def compile (String s) {
		if (s.contains("(")) {
			return "var"+getCounter.toString+"."+s.toString;
		} else {
			return s.toString;
		}
	}
}
