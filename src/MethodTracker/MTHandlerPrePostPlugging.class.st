Class {
	#name : #MTHandlerPrePostPlugging,
	#superclass : #MTHandler,
	#category : #MethodTracker
}

{ #category : #hooks }
MTHandlerPrePostPlugging >> run: aSelector with: anArray in: aReceiver context: aContext tracker: aTracker [

	| result carry |
	carry := aTracker
		         withSuspendWrapping: [ 
			         self
				         run: aSelector
				         with: anArray
				         in: aReceiver
				         preContext: aContext
				         tracker: aTracker ]
		         context: aContext.

	result := super
		          run: aSelector
		          with: anArray
		          in: aReceiver
		          context: aContext
		          tracker: aTracker.

	aTracker
		withSuspendWrapping: [ 
			self
				run: aSelector
				with: anArray
				in: aReceiver
				postContext: aContext
				tracker: aTracker
				carry: carry
				return: result ]
		context: aContext.

	^ result
]

{ #category : #'as yet unclassified' }
MTHandlerPrePostPlugging >> run: aSelector with: anArray in: aReceiver postContext: aContext tracker: aTracker carry: carry return: result [

	
]

{ #category : #'as yet unclassified' }
MTHandlerPrePostPlugging >> run: aSelector with: anArray in: aReceiver preContext: aContext tracker: aTracker [

	
]
