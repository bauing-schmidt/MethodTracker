Class {
	#name : #MTHandlerMemoing,
	#superclass : #MTHandlerDecorating,
	#instVars : [
		'table'
	],
	#category : #MethodTracker
}

{ #category : #'as yet unclassified' }
MTHandlerMemoing >> initialize [

	super initialize.

	table := Dictionary new
]

{ #category : #'as yet unclassified' }
MTHandlerMemoing >> run: aSelector with: anArray in: aReceiver context: aContext wrapper: aWrapper [

	| key missing value |
	aWrapper
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
				           wrapper: aWrapper.

			  aWrapper
				  withSuspendWrapping: [ table at: key put: value ]
				  context: aContext ]
		  ifFalse: [ value ]
]
