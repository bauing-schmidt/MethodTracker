"
I am a wrapper variant that pushes to the standard error output port the method that has been wrapped by me.
"
Class {
	#name : #MWHandlerTracing,
	#superclass : #MWHandler,
	#category : #MethodWrappers
}

{ #category : #evaluation }
MWHandlerTracing >> run: aSelector with: anArray in: aReceiver context: aContext carry: carry wrapper: aWrapper [

	aWrapper
		withSuspendWrapping: [ 
			Stdio stderr
				nextPutAll: aReceiver class name;
				nextPutAll: '>>#';
				nextPutAll: aSelector;
				lf ]
		context: aContext.

	^ super
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  context: aContext
		  carry: carry
		  wrapper: aWrapper
]
