"
I am a wrapper variant that pushes to the standard error output port the method that has been wrapped by me.
"
Class {
	#name : #MWHandlerTracing,
	#superclass : #MWHandler,
	#category : #MethodWrappers
}

{ #category : #evaluation }
MWHandlerTracing >> run: aSelector with: anArray in: aReceiver pre: aContext [

	Stdio stderr
		nextPutAll: aReceiver class name;
		nextPutAll: '>>#';
		nextPutAll: aSelector;
		lf.

	^ super
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  pre: aContext
]
