Class {
	#name : #MTHandlerMemoing,
	#superclass : #MTHandlerTabling,
	#category : #MethodTracker
}

{ #category : #'as yet unclassified' }
MTHandlerMemoing >> run: aSelector with: anArray in: aReceiver context: aContext tracker: aTracker [

	| key missing value |
	aTracker
		withSuspendWrapping: [ 
			| witness |
			witness := Object new.

			key := { 
				       aReceiver.
				       aSelector } , anArray.

			value := table at: key ifAbsent: [ witness ].

			missing := value == witness ]
		context: aContext.

	^ missing
		  ifTrue: [ 
			  value := super
				           run: aSelector
				           with: anArray
				           in: aReceiver
				           context: aContext
				           tracker: aTracker.

			  aTracker
				  withSuspendWrapping: [ table at: key put: value ]
				  context: aContext ]
		  ifFalse: [ value ]
]
