Class {
	#name : #MTHandlerSenderPropagating,
	#superclass : #MTHandlerDecorating,
	#instVars : [
		'walkBlock'
	],
	#category : #MethodTracker
}

{ #category : #hooks }
MTHandlerSenderPropagating >> initialize [

	super initialize.

	self walkBlock: [ :aContext | aContext sender home method ]
]

{ #category : #hooks }
MTHandlerSenderPropagating >> run: aSelector with: anArray in: aReceiver context: aContext tracker: aTracker [

	aTracker
		withSuspendWrapping: [ :session | 
			| tracker additionWitness walkedContext |
			walkedContext := walkBlock value: aContext.

			tracker := MTTracker new
				           compiledMethod: walkedContext;
				           handler: self;
				           yourself.

			additionWitness := session add: tracker.

			additionWitness == tracker ifTrue: [ tracker install ] ]
		context: aContext.

	^ super
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  context: aContext
		  tracker: aTracker
]

{ #category : #accessing }
MTHandlerSenderPropagating >> walkBlock: anObject [

	walkBlock := anObject
]
