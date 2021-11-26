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
			| anAssoc message |
			anAssoc := table at: aContext.
			message := anAssoc value.
			anAssoc value: (message return: anObject copy) ]
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

{ #category : #evaluation }
MWHandlerReceiverArgumentsCopying >> run: aSelector with: anArray in: aReceiver pre: aContext wrapper: aWrapper [

	| result message |
	message := aWrapper
		           withSuspendWrapping: [ 
			           table at: aContext put: (MessageSend
					            receiver: aReceiver copy
					            selector: aSelector
					            arguments: (anArray collect: [ :each | each copy ])) ]
		           context: aContext.

	result := super
		          run: aSelector
		          with: anArray
		          in: aReceiver
		          pre: aContext
		          wrapper: aWrapper.

	aWrapper
		withSuspendWrapping: [ 
			| client |
			client := (handler at: aContext ifAbsent: [ Error signal ])
				          asContextReifiedFromWrapping receiver copy.

			table at: aContext put: client -> message ]
		context: aContext.

	^ result
]
