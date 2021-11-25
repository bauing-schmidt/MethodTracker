"
I am a variant that waits a delay before returning from the hook notification message.
"
Class {
	#name : #MWHandlerExecution,
	#superclass : #MWHandler,
	#instVars : [
		'tree',
		'returns'
	],
	#category : #MethodWrappers
}

{ #category : #initialization }
MWHandlerExecution >> initialize [

	super initialize.

	returns := IdentityDictionary new
]

{ #category : #accessing }
MWHandlerExecution >> metadata: metadata [

	| occurrences ticks selector |
	ticks := 1.

	occurrences := Dictionary new.

	selector := Dictionary new.

	tree
		pre: [ :each | 
			| eachReified key model |
			eachReified := each asContextReifiedFromWrapping.

			model := metadata at: each put: MWModelHandlerProfiling new.

			model reifiedContext: eachReified.

			model parent: (tree parent: each ifAbsent: [ Error signal ]).

			model return: (returns at: each).

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

{ #category : #evaluation }
MWHandlerExecution >> run: aSelector with: anArray in: aReceiver post: aContext carry: carry return: anObject wrapper: aWrapper [

	aWrapper
		withSuspendWrapping: [ returns at: aContext put: anObject ]
		context: aContext.

	^ super
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  post: aContext
		  carry: carry
		  return: anObject
		  wrapper: aWrapper
]

{ #category : #evaluation }
MWHandlerExecution >> run: aSelector with: anArray in: aReceiver pre: aContext wrapper: aWrapper [

	aWrapper
		withSuspendWrapping: [ :aJust | 
			| aParent |
			aParent := aContext sender findContextSuchThat: [ :ctx | 
				           ctx receiver isMethodWrapper and: [ 
					           ctx selector = #run:with:in: ] ].

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
MWHandlerExecution >> tree: aTree [

	tree := aTree
]
