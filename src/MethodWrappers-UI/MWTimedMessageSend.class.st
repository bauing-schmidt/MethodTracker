Class {
	#name : #MWTimedMessageSend,
	#superclass : #Object,
	#instVars : [
		'timespan',
		'messageSend'
	],
	#category : #'MethodWrappers-UI'
}

{ #category : #accessing }
MWTimedMessageSend >> key [

	^ self timespan
]

{ #category : #accessing }
MWTimedMessageSend >> messageSend [

	^ messageSend
]

{ #category : #accessing }
MWTimedMessageSend >> messageSend: anObject [

	messageSend := anObject
]

{ #category : #accessing }
MWTimedMessageSend >> timespan [

	^ timespan
]

{ #category : #accessing }
MWTimedMessageSend >> timespan: anObject [

	timespan := anObject
]

{ #category : #accessing }
MWTimedMessageSend >> value [

	^ self messageSend
]
