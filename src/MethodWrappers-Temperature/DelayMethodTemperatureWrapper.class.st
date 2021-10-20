"
I am a variant that waits a delay before returning from the hook notification message.
"
Class {
	#name : #DelayMethodTemperatureWrapper,
	#superclass : #MethodTemperatureWrapper,
	#classVars : [
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

	  tick := aNumber
]

{ #category : #evaluation }
DelayMethodTemperatureWrapper >> startingOfTimeKey: anArray [

	  ^ super startingOfTimeKey: anArray second
]

{ #category : #'tag keys' }
DelayMethodTemperatureWrapper >> timeKey [

	  tick := tick + 1.

	  ^ { 
		    tick.
		    super timeKey }
]

{ #category : #evaluation }
DelayMethodTemperatureWrapper >> timeKey: anArray duration: duration [

	    super timeKey: anArray second duration: duration
]
