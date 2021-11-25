Extension { #name : #MWHandlerReceiverArgumentsCopying }

{ #category : #'*MethodWrappers-UI' }
MWHandlerReceiverArgumentsCopying >> addColumnsInPresenter: aPresenter metadata: metadata [

	table keysAndValuesDo: [ :each :messageSent | 
		| model ctx messageSend |
		messageSend := messageSent messageSend.
		model := metadata at: each.

		ctx := model reifiedContext.
		model reifiedContext: (Context
				 sender: ctx sender
				 receiver: messageSend receiver
				 method: ctx method
				 arguments: messageSend arguments).

		model return: messageSent return ]
]
