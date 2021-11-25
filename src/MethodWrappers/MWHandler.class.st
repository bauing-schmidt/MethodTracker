Class {
	#name : #MWHandler,
	#superclass : #Object,
	#category : #MethodWrappers
}

{ #category : #hooks }
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
		         pre: aContext
		         wrapper: aWrapper.

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
		  carry: carry
		  return: result
		  wrapper: aWrapper
]

{ #category : #hooks }
MWHandler >> run: aSelector with: anArray in: aReceiver post: aContext carry: carry return: anObject wrapper: aWrapper [

	^ anObject
]

{ #category : #hooks }
MWHandler >> run: aSelector with: anArray in: aReceiver pre: aContext wrapper: aWrapper [

	
]
