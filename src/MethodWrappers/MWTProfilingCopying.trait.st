Trait {
	#name : #MWTProfilingCopying,
	#category : #MethodWrappers
}

{ #category : #collecting }
MWTProfilingCopying >> compiledMethods: methods wrapping: behaviorBlock then: thenBlock [

	| result tree handlerExecution handlerCopying metadata observed |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handlerCopying := MWHandlerReceiverArgumentsCopying new
		                  handler: handlerExecution;
		                  yourself.

	result := (MWSession
		           compiledMethods: methods
		           thenSelect: [ :each | true ])
		          do: [ :each | each handler: handlerCopying ];
		          value: behaviorBlock.

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerCopying metadata: metadata.

	observed := MWObservedDataset new
		            tree: tree;
		            metadata: metadata;
		            yourself.

	^ thenBlock value: result value: observed
]
