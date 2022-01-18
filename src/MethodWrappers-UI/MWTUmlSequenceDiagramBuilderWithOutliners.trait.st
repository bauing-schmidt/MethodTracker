Trait {
	#name : #MWTUmlSequenceDiagramBuilderWithOutliners,
	#category : #'MethodWrappers-UI'
}

{ #category : #'accessing - structure variables' }
MWTUmlSequenceDiagramBuilderWithOutliners >> umlSequenceDiagramBuilder: aBuilder [

	| slotsVisitor block |
	slotsVisitor := MWSlotDescriptorsVisitor new collect: [ :aDescriptor | 
		                aDescriptor
			                headerWithClass;
			                yourself ].

	block := [ :anObject | anObject asShapeSlotsDfsTree: slotsVisitor ].

	^ aBuilder
		  headerShape: block;
		  receiverArgumentsShape: block;
		  yourself
]
