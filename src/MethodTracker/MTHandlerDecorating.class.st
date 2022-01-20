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
MTHandlerDecorating >> run: aSelector with: anArray in: aReceiver context: aContext wrapper: aWrapper [

	^ handler
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  context: aContext
		  wrapper: aWrapper
]
