"
I am a wrapper variant that pushes to the standard error output port the method that has been wrapped by me.
"
Class {
	#name : #MTHandlerTracing,
	#superclass : #MTHandlerPrePostPlugging,
	#category : #MethodTracker
}

{ #category : #evaluation }
MTHandlerTracing >> run: aSelector with: anArray in: aReceiver preContext: aContext tracker: aTracker [

	Stdio stderr
		nextPutAll: aReceiver class name;
		nextPutAll: '>>#';
		nextPutAll: aSelector;
		lf
]
