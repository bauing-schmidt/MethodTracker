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
MWHandlerReceiverArgumentsCopying >> metadata: metadata [

	table keysAndValuesDo: [ :each :anAssoc | 
		| model ctx messageSend messageSent |
		model := metadata at: each.

		messageSent := anAssoc value.
		messageSend := messageSent messageSend.

		ctx := model reifiedContext.

		model reifiedContext: (Context
				 sender: ctx sender
				 receiver: messageSend receiver
				 method: ctx method
				 arguments: messageSend arguments).

		model return: messageSent return.

		model client
			ifNothing: [  ]
			ifJust: [ :aJust | model client: anAssoc key just ] ]
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
			| client clientCopied resultCopied |
			client := (self parent: aContext ifAbsent: [ Error signal ])
				          asContextReifiedFromWrapping receiver.

			clientCopied := copier value: client.
			resultCopied := copier value: result.

			table
				at: aContext
				put: clientCopied -> (message return: resultCopied) ]
		context: aContext.

	^ result
]
