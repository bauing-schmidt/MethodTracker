"
I am a wrapper variant that pushes to the standard error output port the method that has been wrapped by me.
"
Class {
	#name : #MethodTracingWrapper,
	#superclass : #AbstractMethodWrapper,
	#category : #MethodWrappers
}

{ #category : #evaluation }
MethodTracingWrapper >> preRun: aSelector with: anArray in: aReceiver [

	          super preRun: aSelector with: anArray in: aReceiver.

	          Stdio stderr
		          nextPutAll: aReceiver class name;
		          nextPutAll: '>>#';
		          nextPutAll: method selector;
		          lf
]
