Extension { #name : #CompiledMethod }

{ #category : #'*MethodWrappers' }
CompiledMethod >> installWrapper: aWrapper [

	aWrapper installCompiledMethod: self
]
