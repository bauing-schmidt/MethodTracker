Extension { #name : #True }

{ #category : #'*MethodWrappers' }
True >> run: aSelector with: anArray in: aReceiver context: aContext wrapper: aWrapper [

	^ aWrapper
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  context: aContext
		  notSuspended: self
]
