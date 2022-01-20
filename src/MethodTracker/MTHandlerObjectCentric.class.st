Class {
	#name : #MTHandlerObjectCentric,
	#superclass : #MTHandlerDecorating,
	#instVars : [
		'predicate'
	],
	#category : #MethodTracker
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
MTHandlerObjectCentric >> run: aSelector with: anArray in: aReceiver context: aContext tracker: aTracker [

	| shouldForward |
	shouldForward := aTracker
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
				  tracker: aTracker ]
		  ifFalse: [ 
		  aTracker valueWithReceiver: aReceiver arguments: anArray ]
]
