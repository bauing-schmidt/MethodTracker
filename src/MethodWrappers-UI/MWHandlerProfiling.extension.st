Extension { #name : #MWHandlerProfiling }

{ #category : #'*MethodWrappers-UI' }
MWHandlerProfiling >> addColumnsInPresenter: aPresenter [

	| occurrences dict |
	occurrences := Dictionary new.

	dict := IdentityDictionary new.

	tree do: [ :each | 
		| ctx occ key |
		ctx := each asContextReifiedFromWrapping.
		key := { 
			       ctx receiver.
			       ctx selector }.
			
		occ := occurrences at: key ifAbsent: [ 0 ].
		occ := occurrences at: key put: occ + 1.

		dict at: each put: occ ].

	aPresenter
		addColumn:
			(SpStringTableColumn
				 title: 'Message send'
				 evaluated: [ :aContext | 
					 aContext asContextReifiedFromWrapping
						 asStringInterpolationOfReceiverSelectorArguments , ' → '
					 , (self returnAt: aContext ifAbsent: [ '•' ]) asString ]);
		addColumn: (SpStringTableColumn
				 title: 'Send occurrence'
				 evaluated: [ :aContext | dict at: aContext ])
]
