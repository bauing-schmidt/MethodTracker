Class {
	#name : #MWHandlerSuspendPlugging,
	#superclass : #MWHandlerDecorating,
	#instVars : [
		'table',
		'preBlock',
		'postBlock'
	],
	#category : #MethodWrappers
}

{ #category : #hooks }
MWHandlerSuspendPlugging >> initialize [

	super initialize.

	table := Dictionary new
]

{ #category : #accessing }
MWHandlerSuspendPlugging >> post: anObject [

	postBlock := anObject
]

{ #category : #accessing }
MWHandlerSuspendPlugging >> pre: anObject [

	preBlock := anObject
]

{ #category : #hooks }
MWHandlerSuspendPlugging >> run: aSelector with: anArray in: aReceiver context: aContext wrapper: aWrapper [

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
