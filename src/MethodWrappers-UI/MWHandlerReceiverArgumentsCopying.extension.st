Extension { #name : #MWHandlerReceiverArgumentsCopying }

{ #category : #'*MethodWrappers-UI' }
MWHandlerReceiverArgumentsCopying >> addColumnsInPresenter: aPresenter metadata: metadata [

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
