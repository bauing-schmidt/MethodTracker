Class {
	#name : #MTHandler,
	#superclass : #Object,
	#category : #MethodWrappers
}

{ #category : #hooks }
MTHandler >> metadata: metadata [
]

{ #category : #hooks }
MTHandler >> run: aSelector with: anArray in: aReceiver context: aContext wrapper: aWrapper [

	^ aWrapper valueWithReceiver: aReceiver arguments: anArray
]
