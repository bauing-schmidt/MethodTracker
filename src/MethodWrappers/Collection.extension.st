Extension { #name : #Collection }

{ #category : #'*MethodWrappers' }
Collection >> withWrappingDo: aBlock [

	self do: [ :each | each install ].

	^ aBlock ensure: [ self do: [ :each | each uninstall ] ]
]
