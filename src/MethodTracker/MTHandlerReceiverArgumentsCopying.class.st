"
I am a decorator that copy both client, receiver and arguments of each message send.
"
Class {
	#name : #MTHandlerReceiverArgumentsCopying,
	#superclass : #MTHandlerTabling,
	#instVars : [
		'copier'
	],
	#category : #MethodTracker
}

{ #category : #accessing }
MTHandlerReceiverArgumentsCopying >> copyBlock: anObject [

	copier := anObject
]

{ #category : #initialization }
MTHandlerReceiverArgumentsCopying >> initialize [

	super initialize.

	self copyBlock: [ :each | each copy ]
]

{ #category : #hooks }
MTHandlerReceiverArgumentsCopying >> metadata: metadata [

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
			ifJust: [ :aJust | 
			model client: anAssoc key asJustMaybe asCategory ] ]
]

{ #category : #hooks }
MTHandlerReceiverArgumentsCopying >> run: aSelector with: anArray in: aReceiver context: aContext tracker: aTracker [

	| result message |
	message := aTracker
		           withSuspendWrapping: [ 
			           | messageSend |
			           messageSend := MessageSend
				                          receiver: (copier value: aReceiver)
				                          selector: aSelector
				                          arguments: (anArray collect: copier).

			           table at: aContext put: messageSend ]
		           context: aContext.

	result := super
		          run: aSelector
		          with: anArray
		          in: aReceiver
		          context: aContext
		          tracker: aTracker.

	aTracker
		withSuspendWrapping: [ 
			| client clientCopied resultCopied |
			client := (self parent: aContext ifAbsent: [ Error signal ])
				          asArgumentsReifiedContext receiver.

			clientCopied := copier value: client.
			resultCopied := copier value: result.

			table
				at: aContext
				put: clientCopied -> (message return: resultCopied) ]
		context: aContext.

	^ result
]
