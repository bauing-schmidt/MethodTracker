Extension { #name : #MWHandlerProfiling }

{ #category : #'*MethodWrappers-UI' }
MWHandlerProfiling >> addColumnsInPresenter: aPresenter [

	| occurrences dict ticks visit selector methods parent |
	ticks := 1.

	occurrences := Dictionary new.

	dict := IdentityDictionary new.
	visit := IdentityDictionary new.
	selector := Dictionary new.
	methods := Dictionary new.

	parent := tree parent.

	tree
		pre: [ :each | 
			| ctx occ key |
			ctx := each asContextReifiedFromWrapping.
			key := { 
				       ctx receiver.
				       ctx selector }.

			occ := occurrences at: key ifAbsent: [ 0 ].
			occ := occurrences at: key put: occ + 1.

			dict at: each put: occ.

			visit at: each put: ticks @ -1.
			ticks := ticks + 1.

			ctx method in: [ :aMethod | 
				| count |
				count := selector at: aMethod ifAbsent: [ 0 ].
				count := selector at: aMethod put: count + 1.

				methods at: each put: count ] ]
		post: [ :each | 
			visit
				at: each
				ifPresent: [ :aPoint | aPoint setX: aPoint x setY: ticks ]
				ifAbsent: [ Error signal ].
			ticks := ticks + 1 ].

	aPresenter
		addColumn:
			(SpStringTableColumn
				 title: 'Message send'
				 evaluated: [ :aContext | 
					 aContext asContextReifiedFromWrapping
						 asStringInterpolationOfReceiverSelectorArguments ", ' → '
					 , (returns at: aContext ifAbsent: [ '•' ]) asString "]);
		addColumn: (SpStringTableColumn
				 title: 'Return'
				 evaluated: [ :aContext | 
					 (returns at: aContext ifAbsent: [ '•' ]) asString ]);
		addColumn:
			(SpStringTableColumn title: 'Client' evaluated: [ :aContext | 
					 (parent at: aContext) == aContext
						 ifTrue: [ '•' ]
						 ifFalse: [ 
							 (parent at: aContext) asContextReifiedFromWrapping receiver ] ]);
		addColumn: (SpStringTableColumn
				 title: 'Send occurrence'
				 evaluated: [ :aContext | dict at: aContext ]);
		addColumn:
			(SpStringTableColumn
				 title: 'Send progress'
				 evaluated: [ :aContext | 
					 (methods at: aContext)
					 @ (selector at: aContext asContextReifiedFromWrapping method) ]);
		addColumn: (SpStringTableColumn
				 title: 'Entry time @ Exit time'
				 evaluated: [ :aContext | visit at: aContext ])
]
