"
I am a variant that waits a delay before returning from the hook notification message.
"
Class {
	#name : #MWHandlerProfiling,
	#superclass : #MWHandlerPrePostPlugging,
	#instVars : [
		'tree',
		'runWithInMethod',
		'timedReturns',
		'orphans'
	],
	#category : #MethodWrappers
}

{ #category : #initialization }
MWHandlerProfiling >> initialize [

	super initialize.

	runWithInMethod := MWDecorator >> #run:with:in:.

	timedReturns := IdentityDictionary new.

	orphans := OrderedCollection new
]

{ #category : #accessing }
MWHandlerProfiling >> metadata: metadata [

	| occurrences ticks selector |
	ticks := 1.

	occurrences := Dictionary new.

	selector := Dictionary new.

	tree
		pre: [ :each | 
			| eachReified key model timedResult |
			eachReified := each asContextReifiedFromWrapping.

			model := metadata
				         at: each
				         ifAbsentPut: [ MWModelHandlerProfiling new ].

			model reifiedContext: eachReified.

			model parent: (tree parent: each ifAbsent: [ Error signal ]).

			model client: (model parent == each
					 ifTrue: [ Maybe nothing ]
					 ifFalse: [ 
					 (metadata at: model parent) reifiedContext receiver just ]).

			timedResult := timedReturns at: each ifAbsent: [ Error signal ].

			model return: (timedResult result
					 ifNothing: [ '†' ]
					 ifJust: [ :aJust | aJust content ]).

			model duration: (Duration microSeconds: timedResult duration size).

			model startTime:
				(DateAndTime fromSeconds: timedResult duration first / 1e6) asTime.

			key := Array with: eachReified receiver with: eachReified selector.

			model occurrence:
				((occurrences at: key ifAbsent: [ 0 ]) in: [ :occ | 
					 occurrences at: key put: occ + 1 ]).

			model visit: ticks @ 0.
			ticks := ticks + 1.

			eachReified method in: [ :aMethod | 
				| count |
				count := selector at: aMethod ifAbsent: [ 0 ].
				count := selector at: aMethod put: count + 1.
				model count: count ] ]
		post: [ :each | 
			metadata
				at: each
				ifPresent: [ :aMetadata | 
					aMetadata visit in: [ :aPoint | 
						aPoint setX: aPoint x setY: ticks ].
					ticks := ticks + 1 ]
				ifAbsent: [ Error signal ] ].

	metadata keysAndValuesDo: [ :each :model | 
		model total: (selector at: model reifiedContext method) ].

	^ metadata
]

{ #category : #accessing }
MWHandlerProfiling >> parent: aContext ifAbsent: aBlock [

	^ tree parent: aContext ifAbsent: aBlock
]

{ #category : #'as yet unclassified' }
MWHandlerProfiling >> run: aSelector with: anArray in: aReceiver postContext: aContext wrapper: aWrapper carry: timed return: result [

	| duration now by start |
	now := Time microsecondClockValue.
	start := timed duration first.

	by := 1.
	now = start ifTrue: [ now := now + by ].
	duration := start to: now by: by.

	timed
		result: result just;
		duration: duration
]

{ #category : #hooks }
MWHandlerProfiling >> run: aSelector with: anArray in: aReceiver preContext: aContext wrapper: aWrapper [

	| aParent start timedResult |
	aParent := aContext sender findContextSuchThat: [ :ctx | 
		           runWithInMethod = ctx method ].

	aParent
		ifNil: [ 
			orphans add: aContext.
			tree parent: aContext child: aContext ]
		ifNotNil: [ tree parent: aParent child: aContext ].

	start := Time microsecondClockValue.

	timedResult := MWTimedExecResult new
		               result: Maybe nothing;
		               duration: (start to: start + 1);
		               yourself.

	^ timedReturns at: aContext put: timedResult
]

{ #category : #accessing }
MWHandlerProfiling >> tree: aTree [

	tree := aTree
]
