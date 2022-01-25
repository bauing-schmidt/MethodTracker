"
I am a decorator that allows plugging both a pre and a post blocks in a instrumentation-suspended environment.
"
Class {
	#name : #MTHandlerSuspendPlugging,
	#superclass : #MTHandlerDecorating,
	#instVars : [
		'preBlock',
		'postBlock'
	],
	#category : #MethodTracker
}

{ #category : #hooks }
MTHandlerSuspendPlugging >> initialize [

	super initialize.

	self
		pre: [  ];
		post: [  ]
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
MTHandlerSuspendPlugging >> run: aSelector with: anArray in: aReceiver context: aContext tracker: aTracker [

	| result |
	aTracker
		withSuspendWrapping: [ :session | 
		preBlock cull: session cull: aTracker ]
		context: aContext.

	result := super
		          run: aSelector
		          with: anArray
		          in: aReceiver
		          context: aContext
		          tracker: aTracker.

	aTracker
		withSuspendWrapping: [ :session | 
		postBlock cull: session cull: aTracker ]
		context: aContext.

	^ result
]
