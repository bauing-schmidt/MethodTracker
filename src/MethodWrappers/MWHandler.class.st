Class {
	#name : #MWHandler,
	#superclass : #Object,
	#category : #MethodWrappers
}

{ #category : #evaluation }
MWHandler >> run: aSelector with: anArray in: aReceiver post: aContext return: anObject carry: carry [

	            
]

{ #category : #evaluation }
MWHandler >> run: aSelector with: anArray in: aReceiver pre: aContext [

	            
]

{ #category : #'as yet unclassified' }
MWHandler >> runWrapper: aWrapper with: anArray in: aReceiver context: aContext carry: carry [

	^ aWrapper value: aReceiver withArguments: anArray
]
