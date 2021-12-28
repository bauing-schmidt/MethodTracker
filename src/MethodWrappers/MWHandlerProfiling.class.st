"
I am a variant that waits a delay before returning from the hook notification message.
"
Class {
	#name : #MWHandlerProfiling,
	#superclass : #MWHandler,
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

{ #category : #hooks }
MWHandlerProfiling >> run: aSelector with: anArray in: aReceiver context: aContext carry: carry wrapper: aWrapper [

	| start result timed |
	aWrapper
		withSuspendWrapping: [ 
			start := Time microsecondClockValue.
			timed := timedReturns at: aContext ifAbsentPut: [ 
				         MWTimedExecResult new
					         result: Maybe nothing;
					         duration: (start to: start + 1);
					         yourself ] ]
		context: aContext.

	result := aWrapper valueWithReceiver: aReceiver arguments: anArray.

	aWrapper
		withSuspendWrapping: [ 
			| duration now by |
			now := Time microsecondClockValue.
			by := 1.
			now = start ifTrue: [ now := now + by ].
			duration := start to: now by: by.

			timed
				result: result just;
				duration: duration ]
		context: aContext.

	^ result
]

{ #category : #evaluation }
MWHandlerProfiling >> run: aSelector with: anArray in: aReceiver pre: aContext wrapper: aWrapper [

	aWrapper
		withSuspendWrapping: [ :aSession | 
			| aParent |
			aParent := aContext sender findContextSuchThat: [ :ctx | 
				           runWithInMethod = ctx method ].

			aParent
				ifNil: [ 
					orphans add: aContext.
					tree parent: aContext child: aContext ]
				ifNotNil: [ tree parent: aParent child: aContext ] ]
		context: aContext.

	^ super
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  pre: aContext
		  wrapper: aWrapper
]

{ #category : #accessing }
MWHandlerProfiling >> tree: aTree [

	tree := aTree
]
