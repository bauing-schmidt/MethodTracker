Extension { #name : #Collection }

{ #category : #'*MethodWrappers' }
Collection >> withWrappingDo: aBlock [

	SystemAnnouncer uniqueInstance suspendAllWhile: [ 
		self do: [ :each | each install ] ].

	^ aBlock ensure: [ 
		  SystemAnnouncer uniqueInstance suspendAllWhile: [ 
			  self do: [ :each | each uninstall ] ] ]
]
