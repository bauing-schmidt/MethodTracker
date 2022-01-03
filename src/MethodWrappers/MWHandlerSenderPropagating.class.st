Class {
	#name : #MWHandlerSenderPropagating,
	#superclass : #MWHandlerDecorating,
	#category : #MethodWrappers
}

{ #category : #hooks }
MWHandlerSenderPropagating >> run: aSelector with: anArray in: aReceiver context: aContext wrapper: aWrapper [

	aWrapper
		withSuspendWrapping: [ :session | 
			| decorator anAddedDecorator |
			decorator := MWDecorator new
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
		  wrapper: aWrapper
]
