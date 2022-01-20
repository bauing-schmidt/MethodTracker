Class {
	#name : #MTHandlerSuspendPlugging,
	#superclass : #MTHandlerDecorating,
	#instVars : [
		'table',
		'preBlock',
		'postBlock'
	],
	#category : #MethodWrappers
}

{ #category : #hooks }
MTHandlerSuspendPlugging >> initialize [

	super initialize.

	table := Dictionary new
]

{ #category : #accessing }
MTHandlerSuspendPlugging >> post: anObject [

	postBlock := anObject
]

{ #category : #accessing }
MTHandlerSuspendPlugging >> pre: anObject [

	preBlock := anObject
]

{ #category : #hooks }
MTHandlerSuspendPlugging >> run: aSelector with: anArray in: aReceiver context: aContext wrapper: aWrapper [

	| result |
	aWrapper
		withSuspendWrapping: [ :session | 
		preBlock cull: session cull: aWrapper ]
		context: aContext.

	result := super
		          run: aSelector
		          with: anArray
		          in: aReceiver
		          context: aContext
		          wrapper: aWrapper.

	aWrapper
		withSuspendWrapping: [ :session | 
		postBlock cull: session cull: aWrapper ]
		context: aContext.

	^ result
]
