"
I am a variant that waits a delay before returning from the hook notification message.
"
Class {
	#name : #MWHandlerProfiling,
	#superclass : #MWHandler,
	#instVars : [
		'tree',
		'returns'
	],
	#category : #MethodWrappers
}

{ #category : #initialization }
MWHandlerProfiling >> initialize [

	super initialize.

	returns := IdentityDictionary new
]

{ #category : #accessing }
MWHandlerProfiling >> metadata: metadata [

	| occurrences ticks selector |
	ticks := 1.

	occurrences := Dictionary new.

	selector := Dictionary new.

	tree
		pre: [ :each | 
			| eachReified key model |
			eachReified := each asContextReifiedFromWrapping.

			model := metadata at: each put: MWModelHandlerProfiling new.

			model parent: (tree parent: each ifAbsent: [ Error signal ]).

			model return: (returns
					 at: each
					 ifPresent: [ :anObj | CollectionElement with: anObj ]
					 ifAbsent: [ CollectionElement withNil ]).

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
		model total: (selector at: each asContextReifiedFromWrapping method) ].

	^ metadata
]

{ #category : #evaluation }
MWHandlerProfiling >> run: aSelector with: anArray in: aReceiver post: aContext return: anObject carry: carry [

	returns at: aContext put: anObject.

	^ super
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  post: aContext
		  return: anObject
		  carry: carry
]

{ #category : #evaluation }
MWHandlerProfiling >> run: aSelector with: anArray in: aReceiver pre: aContext [

	(aContext sender findContextSuchThat: [ :ctx | 
		 ctx selector = #run:with:in: and: [ ctx receiver isMethodWrapper ] ])
		ifNil: [ tree parent: aContext child: aContext ]
		ifNotNil: [ :parentContext | 
		tree parent: parentContext child: aContext ].

	^ super
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  pre: aContext
]

{ #category : #accessing }
MWHandlerProfiling >> tree: aTree [

	tree := aTree
]
