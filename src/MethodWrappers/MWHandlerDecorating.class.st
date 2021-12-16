Class {
	#name : #MWHandlerDecorating,
	#superclass : #MWHandler,
	#instVars : [
		'handler'
	],
	#category : #MethodWrappers
}

{ #category : #accessing }
MWHandlerDecorating >> at: aContext ifAbsent: aBlock [

	^ handler at: aContext ifAbsent: aBlock
]

{ #category : #accessing }
MWHandlerDecorating >> handler: anObject [

	handler := anObject
]

{ #category : #hooks }
MWHandlerDecorating >> run: aSelector with: anArray in: aReceiver context: aContext carry: carry wrapper: aWrapper [

	^ handler
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  context: aContext
		  carry: carry
		  wrapper: aWrapper
]

{ #category : #evaluation }
MWHandlerDecorating >> run: aSelector with: anArray in: aReceiver post: aContext carry: carry return: anObject wrapper: aWrapper [

	^ handler
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  post: aContext
		  carry: carry
		  return: anObject
		  wrapper: aWrapper
]

{ #category : #evaluation }
MWHandlerDecorating >> run: aSelector with: anArray in: aReceiver pre: aContext wrapper: aWrapper [

	^ handler
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  pre: aContext
		  wrapper: aWrapper
]

{ #category : #accessing }
MWHandlerDecorating >> timedResult [

	^ handler timedResult
]
