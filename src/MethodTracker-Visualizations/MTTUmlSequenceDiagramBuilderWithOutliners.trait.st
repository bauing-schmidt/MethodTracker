"
I am a trait that provides a UML sequence diagram builder configured to use outliners as shapes for objects.
"
Trait {
	#name : #MTTUmlSequenceDiagramBuilderWithOutliners,
	#category : #'MethodTracker-Visualizations'
}

{ #category : #'accessing - structure variables' }
MTTUmlSequenceDiagramBuilderWithOutliners >> umlSequenceDiagramBuilder: aBuilder [

	| slotsVisitor block |
	slotsVisitor := MTSlotDescriptorsVisitor new collect: [ :aDescriptor | 
		                aDescriptor
			                headerWithClass;
			                yourself ].

	block := [ :anObject | 
	         | walker |
	         walker := CTDfsWalker new
		                   slotDescriptorsContext: slotsVisitor;
		                   yourself.

	         anObject asShapeSlotsDfsTree: walker ].

	^ aBuilder
		  headerShape: block;
		  receiverArgumentsShape: block;
		  yourself
]
