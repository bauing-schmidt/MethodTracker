Class {
	#name : #MWHandlerToggling,
	#superclass : #MWHandlerDecorating,
	#instVars : [
		'enable'
	],
	#category : #MethodWrappers
}

{ #category : #initialization }
MWHandlerToggling >> initialize [

	super initialize.

	enable := true
]

{ #category : #hooks }
MWHandlerToggling >> run: aSelector with: anArray in: aReceiver context: aContext carry: carry wrapper: aWrapper [

	^ enable
		  ifTrue: [ 
			  super
				  run: aSelector
				  with: anArray
				  in: aReceiver
				  context: aContext
				  carry: carry
				  wrapper: aWrapper ]
		  ifFalse: [ 
		  aWrapper valueWithReceiver: aReceiver arguments: anArray ]
]

{ #category : #operations }
MWHandlerToggling >> toggle [

	^ enable := enable not
]
