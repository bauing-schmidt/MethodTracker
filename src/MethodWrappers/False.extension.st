Extension { #name : #False }

{ #category : #'*MethodWrappers' }
False >> run: aSelector with: anArray in: aReceiver context: aContext wrapper: aWrapper handler: anHandler [

	^ anHandler
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  context: aContext
		  wrapper: aWrapper
		  false: self
]
