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

	self predicate: [ :recv :args | true ]
]

{ #category : #accessing }
MWHandlerObjectCentric >> predicate: anObject [

	predicate := anObject
]

{ #category : #API }
MWHandlerObjectCentric >> run: aSelector with: anArray in: aReceiver context: aContext wrapper: aWrapper [

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
