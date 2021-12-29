Class {
	#name : #MWHandlerReceiverArgumentsCopying,
	#superclass : #MWHandlerDecorating,
	#instVars : [
		'table',
		'copier'
	],
	#category : #MethodWrappers
}

{ #category : #accessing }
MWHandlerReceiverArgumentsCopying >> copier: anObject [

	copier := anObject
]

{ #category : #initialization }
MWHandlerReceiverArgumentsCopying >> initialize [

	super initialize.

	table := Dictionary new.

	self copier: [ :each | each copy ]
]

{ #category : #hooks }
MWHandlerReceiverArgumentsCopying >> run: aSelector with: anArray in: aReceiver context: aContext wrapper: aWrapper [

	| result message |
	message := aWrapper
		           withSuspendWrapping: [ 
			           table at: aContext put: (MessageSend
					            receiver: (copier value: aReceiver)
					            selector: aSelector
					            arguments: (anArray collect: copier)) ]
		           context: aContext.

	result := super
		          run: aSelector
		          with: anArray
		          in: aReceiver
		          context: aContext
		          wrapper: aWrapper.

	aWrapper
		withSuspendWrapping: [ 
			| client |
			client := copier value:
				          (self parent: aContext ifAbsent: [ Error signal ])
					          asContextReifiedFromWrapping receiver.

			table
				at: aContext
				put: client -> (message return: (copier value: result)) ]
		context: aContext.

	^ result
]
