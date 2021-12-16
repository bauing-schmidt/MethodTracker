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
		table at: aContext put: self timedResult duration ]
		context: aContext.

	^ result
]
