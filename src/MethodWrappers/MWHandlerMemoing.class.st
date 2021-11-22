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

	| key |
	key := { 
		       aReceiver.
		       aSelector } , anArray.

	^ table at: key ifAbsentPut: [ 
		  super
			  run: aSelector
			  with: anArray
			  in: aReceiver
			  context: aContext
			  carry: carry
			  wrapper: aWrapper ]
]
