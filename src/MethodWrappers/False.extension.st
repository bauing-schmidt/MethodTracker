Extension { #name : #False }

{ #category : #'*MethodWrappers' }
False >> run: aSelector with: anArray in: aReceiver context: aContext wrapper: aWrapper [

	^ aWrapper
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  context: aContext
		  suspended: self
]
