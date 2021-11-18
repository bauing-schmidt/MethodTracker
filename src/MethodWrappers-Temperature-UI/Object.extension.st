Extension { #name : #Object }

{ #category : #'*MethodWrappers-Temperature-UI' }
Object >> itself: anObject [

	^ anObject
]

{ #category : #'*MethodWrappers-Temperature-UI' }
Object >> yourself: aBlock [

	"I invoke the given block giving myself as argument if it needs to consume me.
	 Then I return my self discarding the value returned by the given block."

	^ aBlock
		  cull: self;
		  itself: self
]
