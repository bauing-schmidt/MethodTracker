"
I am a variant that waits a delay before returning from the hook notification message.
"
Class {
	#name : #MWHandlerProfiling,
	#superclass : #MWHandler,
	#instVars : [
		'tree',
		'runWithInMethod',
		'timedReturns'
	],
	#category : #MethodWrappers
}

{ #category : #accessing }
MWHandlerProfiling >> at: aContext ifAbsent: aBlock [

	^ tree parent: aContext ifAbsent: aBlock
]

{ #category : #initialization }
MWHandlerProfiling >> initialize [

	super initialize.

	runWithInMethod := MWDecorator >> #run:with:in:.
	
	timedReturns := IdentityDictionary new
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
					 ifTrue: [ Object nothing ]
					 ifFalse: [ 
					 (metadata at: model parent) reifiedContext receiver just ]).

			timedResult := timedReturns at: each.

			model return: timedResult result.

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
				model count:
					((selector at: aMethod ifAbsent: [ 0 ]) in: [ :count | 
						 selector at: aMethod put: count + 1 ]) ] ]
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

{ #category : #hooks }
MWHandlerProfiling >> run: aSelector with: anArray in: aReceiver context: aContext carry: carry wrapper: aWrapper [

	| timedResult |
	aWrapper
		withSuspendWrapping: [ 
			timedResult := MWTimedExecResult new.
			timedReturns at: aContext put: timedResult ]
		context: aContext.

	^ aWrapper
		  valueWithReceiver: aReceiver
		  arguments: anArray
		  timed: timedResult
]

{ #category : #evaluation }
MWHandlerProfiling >> run: aSelector with: anArray in: aReceiver pre: aContext wrapper: aWrapper [

	aWrapper
		withSuspendWrapping: [ :aJust | 
			| aParent |
			aParent := aContext sender findContextSuchThat: [ :ctx | 
				           runWithInMethod = ctx method ].

			aParent
				ifNil: [ tree parent: aContext child: aContext ]
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
