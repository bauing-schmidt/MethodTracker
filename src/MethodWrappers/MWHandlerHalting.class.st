Class {
	#name : #MWHandlerHalting,
	#superclass : #MWHandler,
	#category : #MethodWrappers
}

{ #category : #evaluation }
MWHandlerHalting >> run: aSelector with: anArray in: aReceiver pre: aContext [

	self halt
]

{ #category : #evaluation }
MWHandlerHalting >> run: aSelector with: anArray in: aReceiver pre: aContext wrapper: aWrapper [

	self halt
]
