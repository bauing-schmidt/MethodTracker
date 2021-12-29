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

	^ self
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  context: aContext
		  carry: nil
		  wrapper: aWrapper
]
