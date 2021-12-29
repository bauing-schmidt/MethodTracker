Class {
	#name : #MWHandlerMemoing,
	#superclass : #MWHandlerDecorating,
	#instVars : [
		'table'
	],
	#category : #MethodWrappers
}

{ #category : #'as yet unclassified' }
MWHandlerMemoing >> initialize [

	super initialize.

	table := Dictionary new
]

{ #category : #'as yet unclassified' }
MWHandlerMemoing >> run: aSelector with: anArray in: aReceiver context: aContext wrapper: aWrapper [

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
