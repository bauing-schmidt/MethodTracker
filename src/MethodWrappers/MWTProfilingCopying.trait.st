Trait {
	#name : #MWTProfilingCopying,
	#category : #MethodWrappers
}

{ #category : #'as yet unclassified' }
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

{ #category : #accessing }
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
					           OrderedCollection new.
					           nil } ].

		model statisticsArray: anArray.

		(anArray at: 1) add: ((metadata at: each) client
				 ifNothing: [ Object new ]
				 ifJust: [ :aJust | aJust content ]).
		(anArray at: 2) add: each asContextReifiedFromWrapping receiver.
		anArray at: 3 update: [ :count | count + 1 ].
		(anArray at: 4) add: model duration ].

	tableItems := Dictionary new.

	methodCountDurationDictionary keysAndValuesDo: [ :aMethod :anArray | 
		| row duration durationAvg durationMinSquaresSum count durationStDev durations |
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

		row := Dictionary new
			       at: #compiledMethod put: aMethod;
			       at: #count put: count;
			       at: #duration put: (Duration nanoSeconds: duration);
			       at: #durationAvg put: (Duration nanoSeconds: durationAvg);
			       at: #durationStDev
			       put: (Duration nanoSeconds: durationStDev);
			       at: #clients put: anArray first size;
			       at: #receivers put: anArray second size;
			       yourself.

		tableItems at: aMethod put: row.

		anArray at: 5 put: row ].

	^ tableItems
]
