Extension { #name : #MWHandlerProfiling }

{ #category : #'*MethodWrappers-UI' }
MWHandlerProfiling >> addColumnsInPresenter: aPresenter [

	| metadata |
	metadata := self metadata.

	aPresenter
		addColumn:
			(SpStringTableColumn
				 title: 'Message send'
				 evaluated: [ :aContext | 
					 aContext asContextReifiedFromWrapping
						 asStringInterpolationOfReceiverSelectorArguments ]);
		addColumn:
			(SpStringTableColumn title: 'Return' evaluated: [ :aContext | 
					 (metadata at: aContext) return
						 ifNil: [ '•' ]
						 ifEnclosed: [ :anObj | anObj ] ]);
		addColumn:
			(SpStringTableColumn title: 'Client' evaluated: [ :aContext | 
					 (metadata at: aContext) parent in: [ :aParent | 
							 aParent == aContext
								 ifTrue: [ '•' ]
								 ifFalse: [ aParent asContextReifiedFromWrapping receiver ] ] ]);
		addColumn: (SpStringTableColumn
				 title: 'Send occurrence'
				 evaluated: [ :aContext | (metadata at: aContext) occurrence ]);
		addColumn: (SpStringTableColumn
				 title: 'Send progress'
				 evaluated: [ :aContext | (metadata at: aContext) ratio ]);
		addColumn: (SpStringTableColumn
				 title: 'Entry @ Exit ticks'
				 evaluated: [ :aContext | (metadata at: aContext) visit ])
]

{ #category : #'*MethodWrappers-UI' }
MWHandlerProfiling >> metadata [

	| occurrences ticks selector metadata |
	metadata := IdentityDictionary new.

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
		(selector at: each asContextReifiedFromWrapping method) in: [ :total | 
			model ratio: model count @ total ] ].

	^ metadata
]
