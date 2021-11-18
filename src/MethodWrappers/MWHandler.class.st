Class {
	#name : #MWHandler,
	#superclass : #Object,
	#category : #MethodWrappers
}

{ #category : #'as yet unclassified' }
MWHandler >> run: aSelector with: anArray in: aReceiver context: aContext carry: carry wrapper: aWrapper [

	^ aWrapper value: aReceiver withArguments: anArray
]

{ #category : #evaluation }
MWHandler >> run: aSelector with: anArray in: aReceiver post: aContext return: anObject carry: carry [

	
]

{ #category : #evaluation }
MWHandler >> run: aSelector with: anArray in: aReceiver pre: aContext [

	            
]
