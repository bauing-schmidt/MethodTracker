Class {
	#name : #MTHandlerToggling,
	#superclass : #MTHandlerDecorating,
	#instVars : [
		'enable'
	],
	#category : #MethodWrappers
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
MTHandlerToggling >> run: aSelector with: anArray in: aReceiver context: aContext wrapper: aWrapper [

	^ enable
		  ifTrue: [ 
			  super
				  run: aSelector
				  with: anArray
				  in: aReceiver
				  context: aContext
				  wrapper: aWrapper ]
		  ifFalse: [ 
		  aWrapper valueWithReceiver: aReceiver arguments: anArray ]
]

{ #category : #operations }
MTHandlerToggling >> toggle [

	^ enable := enable not
]
