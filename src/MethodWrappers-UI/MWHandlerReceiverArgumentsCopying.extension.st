Extension { #name : #MWHandlerReceiverArgumentsCopying }

{ #category : #'*MethodWrappers-UI' }
MWHandlerReceiverArgumentsCopying >> addColumnsInPresenter: aPresenter metadata: metadata [

	aPresenter addColumn: (SpStringTableColumn
			 title: 'Return copied'
			 evaluated: [ :aContext | (table at: aContext) return ])
]
