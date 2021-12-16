Class {
	#name : #MWTimedExecResult,
	#superclass : #Object,
	#instVars : [
		'result',
		'duration'
	],
	#category : #MethodWrappers
}

{ #category : #accessing }
MWTimedExecResult >> duration [

	^ duration
]

{ #category : #accessing }
MWTimedExecResult >> duration: anObject [

	duration := anObject
]

{ #category : #accessing }
MWTimedExecResult >> result [

	^ result
]

{ #category : #accessing }
MWTimedExecResult >> result: anObject [

	result := anObject
]
