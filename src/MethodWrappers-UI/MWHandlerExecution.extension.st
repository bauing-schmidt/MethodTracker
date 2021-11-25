Extension { #name : #MWHandlerExecution }

{ #category : #'*MethodWrappers-UI' }
MWHandlerExecution >> addColumnsInPresenter: aPresenter metadata: metadata [

	self metadata: metadata.

	aPresenter
		addColumn:
			(SpStringTableColumn
				 title: 'Message send'
				 evaluated: [ :aContext | 
					 (metadata at: aContext) reifiedContext
						 asStringInterpolationOfReceiverSelectorArguments ]);
		addColumn: (SpStringTableColumn
				 title: 'Return'
				 evaluated: [ :aContext | (metadata at: aContext) return ]);
		addColumn:
			(SpStringTableColumn title: 'Client' evaluated: [ :aContext | 
					 (metadata at: aContext) client
						 ifNothing: [ '•' ]
						 ifJust: [ :aJust | aJust content ] ]);
		addColumn: (SpStringTableColumn
				 title: 'Send occurrence'
				 evaluated: [ :aContext | (metadata at: aContext) occurrence ]);
		addColumn: (SpStringTableColumn
				 title: 'Send progress'
				 evaluated: [ :aContext | (metadata at: aContext) ratio ]);
		addColumn: (SpStringTableColumn
				 title: 'Entry @ Exit ticks'
				 evaluated: [ :aContext | (metadata at: aContext) visit ])
]
