Extension { #name : #Collection }

{ #category : #'*MethodWrappers' }
Collection >> withWrappingDo: aBlock [

	| wrappers |
	wrappers := self collect: [ :each | each install ].

	^ aBlock ensure: [ wrappers do: [ :each | each uninstall ] ]
]
