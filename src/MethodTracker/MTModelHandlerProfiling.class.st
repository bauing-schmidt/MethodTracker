"
I am a handler that keeps the relation among contexts when they are activated because of message sends.
"
Class {
	#name : #MTModelHandlerProfiling,
	#superclass : #Object,
	#instVars : [
		'occurrence',
		'visit',
		'count',
		'parent',
		'return',
		'duration',
		'startTime',
		'total',
		'reifiedContext',
		'client'
	],
	#category : #MethodTracker
}

{ #category : #accessing }
MTModelHandlerProfiling >> client [

	^ client
]

{ #category : #accessing }
MTModelHandlerProfiling >> client: anObject [

	client := anObject
]

{ #category : #accessing }
MTModelHandlerProfiling >> count [

	^ count
]

{ #category : #accessing }
MTModelHandlerProfiling >> count: anObject [

	count := anObject
]

{ #category : #accessing }
MTModelHandlerProfiling >> duration [

	^ duration
]

{ #category : #accessing }
MTModelHandlerProfiling >> duration: anObject [

	duration := anObject
]

{ #category : #accessing }
MTModelHandlerProfiling >> occurrence [

	^ occurrence
]

{ #category : #accessing }
MTModelHandlerProfiling >> occurrence: anObject [

	occurrence := anObject
]

{ #category : #accessing }
MTModelHandlerProfiling >> parent [

	^ parent
]

{ #category : #accessing }
MTModelHandlerProfiling >> parent: anObject [

	parent := anObject
]

{ #category : #accessing }
MTModelHandlerProfiling >> ratio [

	^ self count @ self total
]

{ #category : #accessing }
MTModelHandlerProfiling >> reifiedContext [

	^ reifiedContext
]

{ #category : #accessing }
MTModelHandlerProfiling >> reifiedContext: anObject [

	reifiedContext := anObject
]

{ #category : #accessing }
MTModelHandlerProfiling >> return [

	^ return
]

{ #category : #accessing }
MTModelHandlerProfiling >> return: anObject [

	return := anObject
]

{ #category : #accessing }
MTModelHandlerProfiling >> startTime [

	^ startTime
]

{ #category : #accessing }
MTModelHandlerProfiling >> startTime: anObject [

	startTime := anObject
]

{ #category : #accessing }
MTModelHandlerProfiling >> total [

	^ total
]

{ #category : #accessing }
MTModelHandlerProfiling >> total: anObject [

	total := anObject
]

{ #category : #accessing }
MTModelHandlerProfiling >> visit [

	^ visit
]

{ #category : #accessing }
MTModelHandlerProfiling >> visit: anObject [

	visit := anObject
]

{ #category : #visiting }
MTModelHandlerProfiling >> visitDuration [

	^ self visit yMinusX
]
