Extension { #name : #MWSession }

{ #category : #'*MethodWrappers' }
MWSession >> do: aBlock [

	decorators do: aBlock
]

{ #category : #'*MethodWrappers' }
MWSession >> value: aBlock [

	home := thisContext.

	^ [ self do: [ :each | each install ] ] value: aBlock then: [ 
		  self do: [ :each | each uninstall ].
		  home := nil ]
]
