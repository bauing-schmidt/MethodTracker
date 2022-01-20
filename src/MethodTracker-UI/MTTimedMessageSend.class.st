Class {
	#name : #MTTimedMessageSend,
	#superclass : #Object,
	#instVars : [
		'timespan',
		'messageSend'
	],
	#category : #'MethodTracker-UI'
}

{ #category : #accessing }
MTTimedMessageSend >> messageSend [

	^ messageSend
]

{ #category : #accessing }
MTTimedMessageSend >> messageSend: anObject [

	messageSend := anObject
]

{ #category : #accessing }
MTTimedMessageSend >> timespan [

	^ timespan
]

{ #category : #accessing }
MTTimedMessageSend >> timespan: anObject [

	timespan := anObject
]

{ #category : #accessing }
MTTimedMessageSend >> value [

	self shouldNotBeRedefined
]
