"
I am a wrapper variant that pushes to the standard error output port the method that has been wrapped by me.
"
Class {
	#name : #MethodTracingWrapper,
	#superclass : #AbstractMethodWrapper,
	#category : #MethodWrappers
}

{ #category : #evaluation }
MethodTracingWrapper >> run: aSelector with: anArray in: aReceiver [

	  Stdio stderr
		  nextPutAll: aReceiver class name , '>>#' , aSelector;
		  lf.
	  ^ super run: aSelector with: anArray in: aReceiver
]
