Extension { #name : #Boolean }

{ #category : #'*MethodWrappers' }
Boolean >> run: aSelector with: anArray in: aReceiver context: aContext wrapper: aWrapper handler: anHandler [

	self subclassResponsibility
]
