Class {
	#name : #MWHandlerSuspendPlugging,
	#superclass : #MWHandlerDecorating,
	#instVars : [
		'table',
		'blockClosure'
	],
	#category : #MethodWrappers
}

{ #category : #accessing }
MWHandlerSuspendPlugging >> blockClosure: anObject [

	blockClosure := anObject
]

{ #category : #hooks }
MWHandlerSuspendPlugging >> initialize [

	super initialize.

	table := Dictionary new
]

{ #category : #hooks }
MWHandlerSuspendPlugging >> run: aSelector with: anArray in: aReceiver context: aContext carry: carry wrapper: aWrapper [

	aWrapper
		withSuspendWrapping: [ :session | 
			| anObj |
			anObj := blockClosure cull: session.
			table at: aContext put: anObj ]
		context: aContext.

	^ super
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  context: aContext
		  carry: carry
		  wrapper: aWrapper
]
