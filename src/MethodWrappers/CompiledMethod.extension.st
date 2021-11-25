Extension { #name : #CompiledMethod }

{ #category : #'*MethodWrappers' }
CompiledMethod >> overriddenMethods [

	^ Array streamContents: [ :aStream | 
		  self methodClass withAllSubclassesDo: [ :aClass | 
			  | cm |
			  cm := [ aClass >> self selector ]
				        on: KeyNotFound
				        do: [ nil ].

			  cm ifNotNil: [ aStream nextPut: cm ] ] ]
]
