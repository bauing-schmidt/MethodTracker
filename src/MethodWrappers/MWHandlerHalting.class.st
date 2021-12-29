Class {
	#name : #MWHandlerHalting,
	#superclass : #MWHandler,
	#category : #MethodWrappers
}

{ #category : #evaluation }
MWHandlerHalting >> run: aSelector with: anArray in: aReceiver context: aContext wrapper: aWrapper [

	aWrapper
		withSuspendWrapping: [ Warning signal: 'Proceed when you''re done' ]
		context: aContext.

	^ super
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  context: aContext
		  wrapper: aWrapper
]
