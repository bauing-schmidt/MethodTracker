"
I am a trait that assemble instrumentation using profiling with copying.
"
Trait {
	#name : #MTTProfilingCopying,
	#category : #'MethodTracker-UI'
}

{ #category : #collecting }
MTTProfilingCopying >> compiledMethods: methods wrapping: behaviorBlock then: thenBlock [

	| result tree handlerExecution handlerCopying metadata observed |
	tree := MTContextsTree new.

	handlerExecution := MTHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handlerCopying := MTHandlerReceiverArgumentsCopying new
		                  handler: handlerExecution;
		                  yourself.

	result := (MTSession
		           compiledMethods: methods
		           thenSelect: [ :each | true ])
		          do: [ :each | each handler: handlerCopying ];
		          value: behaviorBlock.

	metadata := IdentityDictionary new.

	handlerExecution metadata: metadata.
	handlerCopying metadata: metadata.

	observed := MTObservedDataset new
		            tree: tree;
		            metadata: metadata;
		            yourself.

	^ thenBlock value: result value: observed
]
