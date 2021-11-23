Extension { #name : #MWHandlerProfiling }

{ #category : #'*MethodWrappers-UI' }
MWHandlerProfiling >> addColumnsInPresenter: aPresenter [

	| metadata |
	metadata := self metadata.

	aPresenter
		addColumn:
			(SpStringTableColumn
				 title: 'Message send'
				 evaluated: [ :aContext | 
					 aContext asContextReifiedFromWrapping
						 asStringInterpolationOfReceiverSelectorArguments ]);
		addColumn:
			(SpStringTableColumn title: 'Return' evaluated: [ :aContext | 
					 (metadata at: aContext) return
						 ifNil: [ '•' ]
						 ifEnclosed: [ :anObj | anObj ] ]);
		addColumn:
			(SpStringTableColumn title: 'Client' evaluated: [ :aContext | 
					 (metadata at: aContext) parent in: [ :aParent | 
							 aParent == aContext
								 ifTrue: [ '•' ]
								 ifFalse: [ aParent asContextReifiedFromWrapping receiver ] ] ]);
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
