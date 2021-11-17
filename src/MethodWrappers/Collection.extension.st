Extension { #name : #Collection }

{ #category : #'*MethodWrappers' }
Collection >> withWrappingDo: aBlock [

	| wrappers |
	wrappers := self
		            select: [ :each | each isMethodWrapper ]
		            thenCollect: [ :each | each install ].

	^ aBlock ensure: [ wrappers do: [ :each | each uninstall ] ]
]
