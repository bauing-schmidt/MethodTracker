"
I am able to accept and customize the execution of a (tracked) compiled method.
"
Class {
	#name : #MTHandler,
	#superclass : #Object,
	#category : #MethodTracker
}

{ #category : #hooks }
MTHandler >> metadata: metadata [
]

{ #category : #hooks }
MTHandler >> run: aSelector with: anArray in: aReceiver context: aContext tracker: aTracker [

	^ aTracker valueWithReceiver: aReceiver arguments: anArray
]
