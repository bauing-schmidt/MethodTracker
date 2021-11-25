Class {
	#name : #MWHandlerReceiverArgumentsCopying,
	#superclass : #MWHandlerDecorating,
	#instVars : [
		'table'
	],
	#category : #MethodWrappers
}

{ #category : #initialization }
MWHandlerReceiverArgumentsCopying >> initialize [

	super initialize.

	table := Dictionary new
]

{ #category : #hooks }
MWHandlerReceiverArgumentsCopying >> run: aSelector with: anArray in: aReceiver post: aContext carry: carry return: anObject wrapper: aWrapper [

	aWrapper
		withSuspendWrapping: [ 
			| message |
			message := table at: aContext.

			table at: aContext put: (message return: anObject copy) ]
		context: aContext.

	^ super
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  post: aContext
		  carry: carry
		  return: anObject
		  wrapper: aWrapper
]

{ #category : #hooks }
MWHandlerReceiverArgumentsCopying >> run: aSelector with: anArray in: aReceiver pre: aContext wrapper: aWrapper [

	aWrapper
		withSuspendWrapping: [ 
			| message |
			message := MessageSend
				           receiver: aReceiver copy
				           selector: aSelector
				           arguments: (anArray collect: [ :each | each copy ]).

			table at: aContext put: message ]
		context: aContext.

	^ super
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  pre: aContext
		  wrapper: aWrapper
]
