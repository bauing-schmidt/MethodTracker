Class {
	#name : #LogicalTimespan,
	#superclass : #Timespan,
	#instVars : [
		'logicalStart',
		'logicalDuration'
	],
	#category : #'MethodWrappers-Temperature'
}

{ #category : #accessing }
LogicalTimespan >> logicalDuration [

	^ logicalDuration
]

{ #category : #accessing }
LogicalTimespan >> logicalDuration: anObject [

	logicalDuration := anObject
]

{ #category : #accessing }
LogicalTimespan >> logicalStart [

	^ logicalStart
]

{ #category : #accessing }
LogicalTimespan >> logicalStart: anObject [

	logicalStart := anObject
]
