Class {
	#name : #MWHandlerToggling,
	#superclass : #MWHandlerDecorating,
	#instVars : [
		'enable'
	],
	#category : #MethodWrappers
}

{ #category : #operations }
MWHandlerToggling >> activate [

	enable := true
]

{ #category : #operations }
MWHandlerToggling >> deactivate [

	enable := false
]

{ #category : #initialization }
MWHandlerToggling >> initialize [

	super initialize.

	enable := true
]

{ #category : #hooks }
MWHandlerToggling >> run: aSelector with: anArray in: aReceiver context: aContext wrapper: aWrapper [

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
MWHandlerToggling >> toggle [

	^ enable := enable not
]
