Class {
	#name : #TimespanDiscrete,
	#superclass : #Timespan,
	#instVars : [
		'logicalStart',
		'logicalDuration'
	],
	#category : #'MethodTracker-UI'
}

{ #category : #accessing }
TimespanDiscrete >> logicalDuration [

	^ logicalDuration
]

{ #category : #accessing }
TimespanDiscrete >> logicalDuration: anObject [

	logicalDuration := anObject
]

{ #category : #accessing }
TimespanDiscrete >> logicalEnd [

	^ self logicalStart + self logicalDuration
]

{ #category : #accessing }
TimespanDiscrete >> logicalStart [

	^ logicalStart
]

{ #category : #accessing }
TimespanDiscrete >> logicalStart: anObject [

	logicalStart := anObject
]
