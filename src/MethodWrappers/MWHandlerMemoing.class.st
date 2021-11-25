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
MWHandlerMemoing >> run: aSelector with: anArray in: aReceiver context: aContext carry: carry wrapper: aWrapper [

	| key witness resolved |
	resolved := aWrapper
		            withSuspendWrapping: [ 
			            witness := Object new.

			            key := { 
				                   aReceiver.
				                   aSelector } , anArray.

			            table at: key ifAbsent: [ witness ] ]
		            context: aContext.

	^ resolved == witness
		  ifTrue: [ 
			  | value |
			  value := super
				           run: aSelector
				           with: anArray
				           in: aReceiver
				           context: aContext
				           carry: carry
				           wrapper: aWrapper.

			  aWrapper
				  withSuspendWrapping: [ table at: key put: value ]
				  context: aContext ]
		  ifFalse: [ resolved ]
]
