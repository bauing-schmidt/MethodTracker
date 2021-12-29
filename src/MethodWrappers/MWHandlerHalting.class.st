Class {
	#name : #MWHandlerHalting,
	#superclass : #MWHandlerPrePostPlugging,
	#category : #MethodWrappers
}

{ #category : #evaluation }
MWHandlerHalting >> run: aSelector with: anArray in: aReceiver preContext: aContext wrapper: aWrapper [

	Warning signal: 'Proceed when you''re done'
]
