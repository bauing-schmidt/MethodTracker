Extension { #name : #MTSession }

{ #category : #'*MethodWrappers' }
MTSession >> do: aBlock [

	trackers valuesDo: aBlock
]

{ #category : #'*MethodWrappers' }
MTSession >> value: aBlock [

	"Save the current context as 'root' for the following computation."

	home := thisContext.

	^ [ 
	  self do: [ :each | each install ].
	  aBlock value ] ensure: [ 
		  self do: [ :each | each uninstall ].
		  home := nil ]
]
