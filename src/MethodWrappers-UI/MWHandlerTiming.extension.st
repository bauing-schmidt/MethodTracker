Extension { #name : #MWHandlerTiming }

{ #category : #'*MethodWrappers-UI' }
MWHandlerTiming >> metadata: metadata [

	table keysAndValuesDo: [ :each :interval | 
		| model |
		model := metadata
			         at: each
			         ifAbsentPut: [ MWModelHandlerProfiling new ].

		model duration: (Duration microSeconds: interval size).

		model startTime:
			(DateAndTime fromSeconds: interval first / 1e6) asTime ]
]
