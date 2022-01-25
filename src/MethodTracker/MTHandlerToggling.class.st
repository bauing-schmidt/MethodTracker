"
I am a decorator that alternate the delegation to my handler according to my `enable` state.
"
Class {
	#name : #MTHandlerToggling,
	#superclass : #MTHandlerDecorating,
	#instVars : [
		'enable'
	],
	#category : #MethodTracker
}

{ #category : #operations }
MTHandlerToggling >> activate [

	enable := true
]

{ #category : #operations }
MTHandlerToggling >> deactivate [

	enable := false
]

{ #category : #initialization }
MTHandlerToggling >> initialize [

	super initialize.

	enable := true
]

{ #category : #hooks }
MTHandlerToggling >> run: aSelector with: anArray in: aReceiver context: aContext tracker: aTracker [

	^ enable
		  ifTrue: [ 
			  super
				  run: aSelector
				  with: anArray
				  in: aReceiver
				  context: aContext
				  tracker: aTracker ]
		  ifFalse: [ 
		  aTracker valueWithReceiver: aReceiver arguments: anArray ]
]

{ #category : #operations }
MTHandlerToggling >> toggle [

	^ enable := enable not
]
