Class {
	#name : #MWHandler,
	#superclass : #Object,
	#category : #MethodWrappers
}

{ #category : #'as yet unclassified' }
MWHandler >> run: aSelector with: anArray in: aReceiver context: aContext carry: carry wrapper: aWrapper [

	^ aWrapper valueWithReceiver: aReceiver arguments: anArray
]

{ #category : #API }
MWHandler >> run: aSelector with: anArray in: aReceiver context: aContext wrapper: aWrapper [

	| carry result |
	carry := self
		         run: aSelector
		         with: anArray
		         in: aReceiver
		         pre: aContext.

	result := self
		          run: aSelector
		          with: anArray
		          in: aReceiver
		          context: aContext
		          carry: carry
		          wrapper: aWrapper.

	^ self
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  post: aContext
		  return: result
		  carry: carry
]

{ #category : #evaluation }
MWHandler >> run: aSelector with: anArray in: aReceiver post: aContext return: anObject carry: carry [

	^ anObject
]

{ #category : #evaluation }
MWHandler >> run: aSelector with: anArray in: aReceiver pre: aContext [

	            
]
