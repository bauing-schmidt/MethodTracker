Extension { #name : #MWHandlerProfiling }

{ #category : #'*MethodWrappers-UI' }
MWHandlerProfiling >> addColumnsInPresenter: aPresenter [

	| occurrences dict ticks visit selector |
	ticks := 1.

	occurrences := Dictionary new.

	dict := IdentityDictionary new.
	visit := IdentityDictionary new.
	selector := Dictionary new.

	tree
		pre: [ :each | 
			| ctx occ key count |
			ctx := each asContextReifiedFromWrapping.
			key := { 
				       ctx receiver.
				       ctx selector }.

			occ := occurrences at: key ifAbsent: [ 0 ].
			occ := occurrences at: key put: occ + 1.

			dict at: each put: occ.

			visit at: each put: ticks @ -1.
			ticks := ticks + 1.

			count := selector at: ctx selector ifAbsent: [ 0 ].
			selector at: ctx selector put: count + 1 ]
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
						 asStringInterpolationOfReceiverSelectorArguments , ' → '
					 , (returns at: aContext ifAbsent: [ '•' ]) asString ]);
		addColumn: (SpStringTableColumn
				 title: 'Send occurrence'
				 evaluated: [ :aContext | dict at: aContext ]);
		addColumn: (SpStringTableColumn
				 title: 'Selector sends'
				 evaluated: [ :aContext | 
					 selector at: aContext asContextReifiedFromWrapping selector ]);
		addColumn: (SpStringTableColumn
				 title: 'Entry time @ Exit time'
				 evaluated: [ :aContext | visit at: aContext ])
]
