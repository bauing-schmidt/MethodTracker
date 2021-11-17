"
I am a wrapper variant that pushes to the standard error output port the method that has been wrapped by me.
"
Class {
	#name : #MethodTracingWrapper,
	#superclass : #MethodWrapperHandler,
	#category : #MethodWrappers
}

{ #category : #evaluation }
MethodTracingWrapper >> run: aSelector with: anArray in: aReceiver pre: aContext [

	super
		run: aSelector
		with: anArray
		in: aReceiver
		pre: aContext.

	Stdio stderr
		nextPutAll: aReceiver class name;
		nextPutAll: '>>#';
		nextPutAll: aSelector;
		lf
]
