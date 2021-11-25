Class {
	#name : #MWHandlerTiming,
	#superclass : #MWHandlerDecorating,
	#instVars : [
		'table'
	],
	#category : #MethodWrappers
}

{ #category : #initialization }
MWHandlerTiming >> initialize [

	super initialize.

	table := IdentityDictionary new
]

{ #category : #evaluation }
MWHandlerTiming >> run: aSelector with: anArray in: aReceiver post: aContext carry: carry return: anObject wrapper: aWrapper [

	| result |
	result := super
		          run: aSelector
		          with: anArray
		          in: aReceiver
		          post: aContext
		          carry: carry
		          return: anObject
		          wrapper: aWrapper.

	aWrapper
		withSuspendWrapping: [ 
			| now start by |
			now := Time microsecondClockValue.
			start := table at: aContext.
			by := 1.
			now = start ifTrue: [ now := now + by ].

			table at: aContext put: (start to: now by: by) ]
		context: aContext.

	^ result
]

{ #category : #evaluation }
MWHandlerTiming >> run: aSelector with: anArray in: aReceiver pre: aContext wrapper: aWrapper [

	"It is important to keep the given order to properly record timings."

	aWrapper
		withSuspendWrapping: [ 
			| now |
			now := Time microsecondClockValue.
			table at: aContext put: now ]
		context: aContext.

	^ super
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  pre: aContext
		  wrapper: aWrapper
]
