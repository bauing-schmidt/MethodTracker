Extension { #name : #Collection }

{ #category : #'*MethodWrappers' }
Collection >> withWrappingDo: aBlock [

	^ [ self do: [ :each | each install ] ]
		  value: aBlock
		  then: [ self do: [ :each | each uninstall ] ]
]
