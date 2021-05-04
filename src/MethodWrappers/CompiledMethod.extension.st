Extension { #name : #CompiledMethod }

{ #category : #'*MethodWrappers' }
CompiledMethod >> installWrapper: aWrapper [

	self methodClass methodDict at: self selector put: aWrapper.
	aWrapper hasBeenInstalled
]
