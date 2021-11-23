Extension { #name : #MWHandlerTiming }

{ #category : #'*MethodWrappers-UI' }
MWHandlerTiming >> addColumnsInPresenter: aPresenter [

	aPresenter
		addColumn:
			(SpStringTableColumn title: 'Duration' evaluated: [ :aContext | 
					 | interval |
					 interval := timing at: aContext.
					 (Duration nanoSeconds: interval size * 1000)
						 asStringScaledUptoHours ]);
		addColumn:
			(SpStringTableColumn title: 'Start time' evaluated: [ :aContext | 
					 | interval |
					 interval := timing at: aContext.
					 Time seconds: 0 nanoSeconds: interval first * 1000 ])
]
