Class {
	#name : #MTObservedDataset,
	#superclass : #Object,
	#instVars : [
		'tree',
		'metadata'
	],
	#category : #MethodWrappers
}

{ #category : #accessing }
MTObservedDataset >> metadata [

	^ metadata
]

{ #category : #accessing }
MTObservedDataset >> metadata: anObject [

	metadata := anObject
]

{ #category : #accessing }
MTObservedDataset >> statistics [

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
		anArray second add: each asArgumentsReifiedContext receiver.

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

		sample := MTObservedDatarow new
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

{ #category : #accessing }
MTObservedDataset >> tree [

	^ tree
]

{ #category : #accessing }
MTObservedDataset >> tree: anObject [

	tree := anObject
]
