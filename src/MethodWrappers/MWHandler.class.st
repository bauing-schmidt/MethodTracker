Class {
	#name : #MWHandler,
	#superclass : #Object,
	#category : #MethodWrappers
}

{ #category : #hooks }
MWHandler >> metadata: metadata [
]

{ #category : #hooks }
MWHandler >> run: aSelector with: anArray in: aReceiver context: aContext wrapper: aWrapper [

	^ aWrapper valueWithReceiver: aReceiver arguments: anArray
]
