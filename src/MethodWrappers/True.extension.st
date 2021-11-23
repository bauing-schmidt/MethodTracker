Extension { #name : #True }

{ #category : #'*MethodWrappers' }
True >> run: aSelector with: anArray in: aReceiver context: aContext wrapper: aWrapper handler: anHandler [

	^ anHandler
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  context: aContext
		  wrapper: aWrapper
		  true: self
]
