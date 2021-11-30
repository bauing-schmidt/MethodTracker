Extension { #name : #MWHandlerTiming }

{ #category : #'*MethodWrappers-UI' }
MWHandlerTiming >> addColumnsInPresenter: aPresenter metadata: metadata [

	table keysAndValuesDo: [ :each :interval | 
		| model |
		model := metadata
			         at: each
			         ifAbsentPut: [ MWModelHandlerProfiling new ].

		model duration: (Duration microSeconds: interval size).

		model startTime:
			(DateAndTime fromSeconds: interval first / 1e6) asTime ].

	aPresenter
		addColumn:
			(SpStringTableColumn title: 'Duration' evaluated: [ :aContext | 
					 (metadata at: aContext) duration asStringScaledUptoHours ]);
		addColumn: (SpStringTableColumn
				 title: 'Start time'
				 evaluated: [ :aContext | (metadata at: aContext) startTime ])
]
