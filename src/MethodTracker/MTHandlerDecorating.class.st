"
I am a decorator of a given handler, delegating to it the responsibility to actually do behavior.
"
Class {
	#name : #MTHandlerDecorating,
	#superclass : #MTHandler,
	#instVars : [
		'handler'
	],
	#category : #MethodTracker
}

{ #category : #accessing }
MTHandlerDecorating >> handler: anObject [

	handler := anObject
]

{ #category : #accessing }
MTHandlerDecorating >> parent: aContext ifAbsent: aBlock [

	^ handler parent: aContext ifAbsent: aBlock
]

{ #category : #hooks }
MTHandlerDecorating >> run: aSelector with: anArray in: aReceiver context: aContext tracker: aTracker [

	^ handler
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  context: aContext
		  tracker: aTracker
]
