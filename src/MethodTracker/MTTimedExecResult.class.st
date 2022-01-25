"
I am a data object for the profiling handler.
"
Class {
	#name : #MTTimedExecResult,
	#superclass : #Object,
	#instVars : [
		'result',
		'duration'
	],
	#category : #MethodTracker
}

{ #category : #accessing }
MTTimedExecResult >> duration [

	^ duration
]

{ #category : #accessing }
MTTimedExecResult >> duration: anObject [

	duration := anObject
]

{ #category : #accessing }
MTTimedExecResult >> result [

	^ result
]

{ #category : #accessing }
MTTimedExecResult >> result: anObject [

	result := anObject
]
