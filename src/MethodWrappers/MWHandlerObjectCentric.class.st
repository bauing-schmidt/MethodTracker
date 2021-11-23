Class {
	#name : #MWHandlerObjectCentric,
	#superclass : #MWHandlerDecorating,
	#instVars : [
		'predicate'
	],
	#category : #MethodWrappers
}

{ #category : #initialization }
MWHandlerObjectCentric >> initialize [

	super initialize.

	predicate := [ :recv :args | true ]
]

{ #category : #accessing }
MWHandlerObjectCentric >> predicate: anObject [

	predicate := anObject
]

{ #category : #API }
MWHandlerObjectCentric >> run: aSelector with: anArray in: aReceiver context: aContext wrapper: aWrapper [

	| shouldForward |
	shouldForward := [ predicate value: aReceiver value: anArray ]
		                 on: MessageNotUnderstood
		                 do: [ false ].

	^ shouldForward
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
