Trait {
	#name : #MTTUmlSequenceDiagramBuilderWithOutliners,
	#category : #'MethodTracker-UI'
}

{ #category : #'accessing - structure variables' }
MTTUmlSequenceDiagramBuilderWithOutliners >> umlSequenceDiagramBuilder: aBuilder [

	| slotsVisitor block |
	slotsVisitor := MTSlotDescriptorsVisitor new collect: [ :aDescriptor | 
		                aDescriptor
			                headerWithClass;
			                yourself ].

	block := [ :anObject | anObject asShapeSlotsDfsTree: slotsVisitor ].

	^ aBuilder
		  headerShape: block;
		  receiverArgumentsShape: block;
		  yourself
]
