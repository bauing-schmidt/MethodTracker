Class {
	#name : #MWModelHandlerProfiling,
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
		'reifiedContext'
	],
	#category : #MethodWrappers
}

{ #category : #accessing }
MWModelHandlerProfiling >> count [

	^ count
]

{ #category : #accessing }
MWModelHandlerProfiling >> count: anObject [

	count := anObject
]

{ #category : #accessing }
MWModelHandlerProfiling >> duration [

	^ duration
]

{ #category : #accessing }
MWModelHandlerProfiling >> duration: anObject [

	duration := anObject
]

{ #category : #accessing }
MWModelHandlerProfiling >> occurrence [

	^ occurrence
]

{ #category : #accessing }
MWModelHandlerProfiling >> occurrence: anObject [

	occurrence := anObject
]

{ #category : #accessing }
MWModelHandlerProfiling >> parent [

	^ parent
]

{ #category : #accessing }
MWModelHandlerProfiling >> parent: anObject [

	parent := anObject
]

{ #category : #accessing }
MWModelHandlerProfiling >> ratio [

	^ self count @ self total
]

{ #category : #accessing }
MWModelHandlerProfiling >> reifiedContext [

	^ reifiedContext
]

{ #category : #accessing }
MWModelHandlerProfiling >> reifiedContext: anObject [

	reifiedContext := anObject
]

{ #category : #accessing }
MWModelHandlerProfiling >> return [

	^ return
]

{ #category : #accessing }
MWModelHandlerProfiling >> return: anObject [

	return := anObject
]

{ #category : #accessing }
MWModelHandlerProfiling >> startTime [

	^ startTime
]

{ #category : #accessing }
MWModelHandlerProfiling >> startTime: anObject [

	startTime := anObject
]

{ #category : #accessing }
MWModelHandlerProfiling >> total [

	^ total
]

{ #category : #accessing }
MWModelHandlerProfiling >> total: anObject [

	total := anObject
]

{ #category : #accessing }
MWModelHandlerProfiling >> visit [

	^ visit
]

{ #category : #accessing }
MWModelHandlerProfiling >> visit: anObject [

	visit := anObject
]

{ #category : #visiting }
MWModelHandlerProfiling >> visitDuration [

	^ self visit yMinusX
]
