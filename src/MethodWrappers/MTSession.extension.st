Extension { #name : #MTSession }

{ #category : #'*MethodWrappers' }
MTSession >> do: aBlock [

	decorators valuesDo: aBlock
]

{ #category : #'*MethodWrappers' }
MTSession >> value: aBlock [

	"Save the current context as 'root' for the following computation."

	home := thisContext.

	^ [ self do: [ :each | each install ] ] value: aBlock then: [ 
		  self do: [ :each | each uninstall ].
		  home := nil ]
]
