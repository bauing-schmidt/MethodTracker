Class {
	#name : #MTHandlerHalting,
	#superclass : #MTHandlerPrePostPlugging,
	#category : #MethodTracker
}

{ #category : #evaluation }
MTHandlerHalting >> run: aSelector with: anArray in: aReceiver preContext: aContext wrapper: aWrapper [

	Warning signal: 'Proceed when you''re done'
]
