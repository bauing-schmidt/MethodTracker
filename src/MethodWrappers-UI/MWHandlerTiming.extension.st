Extension { #name : #MWHandlerTiming }

{ #category : #'*MethodWrappers-UI' }
MWHandlerTiming >> addColumnsInPresenter: aPresenter [

	aPresenter addColumn: (SpStringTableColumn
			 title: 'Duration'
			 evaluated: [ :aContext | 
			 (self durationAt: aContext) asStringScaledUptoHours ])
]
