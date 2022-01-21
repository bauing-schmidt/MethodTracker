"
I am a handler that just count message sends.
"
Class {
	#name : #MTHandlerCounting,
	#superclass : #MTHandlerPrePostPlugging,
	#instVars : [
		'count'
	],
	#category : #MethodTracker
}

{ #category : #evaluation }
MTHandlerCounting >> add: a to: b [

	^ a addNumber: b
]

{ #category : #accessing }
MTHandlerCounting >> count [ 

	^ count
]

{ #category : #initialization }
MTHandlerCounting >> initialize [

	super initialize.

	count := 0
]

{ #category : #evaluation }
MTHandlerCounting >> run: aSelector with: anArray in: aReceiver preContext: aContext tracker: aTracker [

	count := self add: count to: 1
]
