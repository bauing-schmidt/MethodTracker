"
I am a variant that waits a delay before returning from the hook notification message.
"
Class {
	#name : #DelayMethodTemperatureWrapper,
	#superclass : #MethodTemperatureWrapper,
	#classVars : [
		'mutex',
		'tick'
	],
	#category : #'MethodWrappers-Temperature'
}

{ #category : #initialization }
DelayMethodTemperatureWrapper class >> initialize [

	  self tick: 0
]

{ #category : #'as yet unclassified' }
DelayMethodTemperatureWrapper class >> tick: aNumber [

	    tick := aNumber.
	    mutex := Semaphore forMutualExclusion
]

{ #category : #evaluation }
DelayMethodTemperatureWrapper >> startingOfTimeKey: anArray [

	  ^ super startingOfTimeKey: anArray second
]

{ #category : #'tag keys' }
DelayMethodTemperatureWrapper >> timeKey [

	        ^ mutex critical: [ 
		          { 
			          tick.
			          super timeKey } yourself: [ tick := tick + 1 ] ]
]

{ #category : #evaluation }
DelayMethodTemperatureWrapper >> timeKey: anArray duration: duration [

	    super timeKey: anArray second duration: duration
]
