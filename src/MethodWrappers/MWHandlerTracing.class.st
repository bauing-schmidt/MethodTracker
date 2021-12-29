"
I am a wrapper variant that pushes to the standard error output port the method that has been wrapped by me.
"
Class {
	#name : #MWHandlerTracing,
	#superclass : #MWHandlerPrePostPlugging,
	#category : #MethodWrappers
}

{ #category : #evaluation }
MWHandlerTracing >> run: aSelector with: anArray in: aReceiver preContext: aContext wrapper: aWrapper [

	Stdio stderr
		nextPutAll: aReceiver class name;
		nextPutAll: '>>#';
		nextPutAll: aSelector;
		lf
]
