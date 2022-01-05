Trait {
	#name : #MWTProfilingCopying,
	#category : #MethodWrappers
}

{ #category : #collecting }
MWTProfilingCopying >> compiledMethods: methods wrapping: behaviorBlock then: thenBlock [

	| result tree handlerExecution handlerCopying metadata observed |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handlerCopying := MWHandlerReceiverArgumentsCopying new
		                  handler: handlerExecution;
		                  yourself.

	result := (MWSession
		           compiledMethods: methods
		           thenSelect: [ :each | true ])
		          do: [ :each | each handler: handlerCopying ];
		          value: behaviorBlock.

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerCopying metadata: metadata.

	observed := MWObservedData new
		            tree: tree;
		            metadata: metadata;
		            statistics: (self statistics: metadata);
		            yourself.

	^ thenBlock value: result value: observed
]

{ #category : #collecting }
MWTProfilingCopying >> statistics: metadata [

	| methodCountDurationDictionary tableItems |
	methodCountDurationDictionary := Dictionary new.

	metadata keysAndValuesDo: [ :each :model | 
		| anArray |
		anArray := methodCountDurationDictionary
			           at: model reifiedContext method
			           ifAbsentPut: [ 
				           { 
					           IdentitySet new.
					           IdentitySet new.
					           0.
					           OrderedCollection new } ].

		"Clients."
		anArray first add: ((metadata at: each) client
				 ifNothing: [ Object new ]
				 ifJust: [ :aJust | aJust content ]).

		"Receivers."
		anArray second add: each asContextReifiedFromWrapping receiver.

		"Count."
		anArray at: 3 update: [ :count | count + 1 ].

		"Durations."
		anArray fourth add: model duration ].

	tableItems := Dictionary new.

	methodCountDurationDictionary keysAndValuesDo: [ :aMethod :anArray | 
		| duration durationAvg durationMinSquaresSum count durationStDev durations sample |
		count := anArray third.
		durations := anArray fourth.

		duration := durations
			            inject: 0
			            into: [ :nanoSecs :each | 
			            nanoSecs + each asNanoSeconds ].

		durationAvg := duration / count.

		durationMinSquaresSum := durations
			                         inject: 0
			                         into: [ :nanoSecs :each | 
				                         | error |
				                         error := each asNanoSeconds - durationAvg.
				                         nanoSecs + error squared ].

		durationStDev := count > 1
			                 ifTrue: [ 
			                 (durationMinSquaresSum / (count - 1)) sqrt ]
			                 ifFalse: [ 0 ].

		sample := MWObservedSample new
			          compiledMethod: aMethod;
			          count: count;
			          duration: (Duration nanoSeconds: duration);
			          durationAvg: (Duration nanoSeconds: durationAvg);
			          durationStDev: (Duration nanoSeconds: durationStDev);
			          clients: anArray first size;
			          receivers: anArray second size;
			          yourself.

		tableItems at: aMethod put: sample ].

	^ tableItems
]
