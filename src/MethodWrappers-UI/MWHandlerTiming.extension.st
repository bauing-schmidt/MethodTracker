Extension { #name : #MWHandlerTiming }

{ #category : #'*MethodWrappers-UI' }
MWHandlerTiming >> addColumnsInPresenter: aPresenter metadata: metadata [

	timing keysAndValuesDo: [ :each :interval | 
		| model |
		model := metadata
			         at: each
			         ifAbsentPut: [ MWModelHandlerProfiling new ].

		model duration: (Duration nanoSeconds: interval size * 1000).

		model startTime:
			(Time seconds: 0 nanoSeconds: interval first * 1000) ].

	aPresenter
		addColumn:
			(SpStringTableColumn title: 'Duration' evaluated: [ :aContext | 
					 (metadata at: aContext) duration asStringScaledUptoHours ]);
		addColumn: (SpStringTableColumn
				 title: 'Start time'
				 evaluated: [ :aContext | (metadata at: aContext) startTime ])
]
