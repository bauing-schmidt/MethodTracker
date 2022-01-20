Class {
	#name : #MTHandlerSenderPropagating,
	#superclass : #MTHandlerDecorating,
	#category : #MethodTracker
}

{ #category : #hooks }
MTHandlerSenderPropagating >> run: aSelector with: anArray in: aReceiver context: aContext tracker: aTracker [

	aTracker
		withSuspendWrapping: [ :session | 
			| decorator anAddedDecorator |
			decorator := MTTracker new
				             compiledMethod: aContext sender home method;
				             handler: self;
				             yourself.

			anAddedDecorator := session add: decorator.

			anAddedDecorator == decorator ifTrue: [ decorator install ] ]
		context: aContext.

	^ super
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  context: aContext
		  tracker: aTracker
]
