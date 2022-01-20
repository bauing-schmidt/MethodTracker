Class {
	#name : #MTHandlerObjectCentric,
	#superclass : #MTHandlerDecorating,
	#instVars : [
		'predicate'
	],
	#category : #MethodWrappers
}

{ #category : #initialization }
MTHandlerObjectCentric >> initialize [

	super initialize.

	self predicate: [ :recv :args | true ]
]

{ #category : #accessing }
MTHandlerObjectCentric >> predicate: anObject [

	predicate := anObject
]

{ #category : #API }
MTHandlerObjectCentric >> run: aSelector with: anArray in: aReceiver context: aContext wrapper: aWrapper [

	| shouldForward |
	shouldForward := aWrapper
		                 withSuspendWrapping: [ 
			                 [ predicate value: aReceiver value: anArray ]
				                 on: MessageNotUnderstood
				                 do: [ false ] ]
		                 context: aContext.

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
