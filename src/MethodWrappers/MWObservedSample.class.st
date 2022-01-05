Class {
	#name : #MWObservedSample,
	#superclass : #Object,
	#instVars : [
		'compiledMethod',
		'count',
		'duration',
		'durationAvg',
		'durationStDev',
		'clients',
		'receivers'
	],
	#category : #MethodWrappers
}

{ #category : #accessing }
MWObservedSample >> clients [

	^ clients
]

{ #category : #accessing }
MWObservedSample >> clients: anObject [

	clients := anObject
]

{ #category : #accessing }
MWObservedSample >> compiledMethod [

	^ compiledMethod
]

{ #category : #accessing }
MWObservedSample >> compiledMethod: anObject [

	compiledMethod := anObject
]

{ #category : #accessing }
MWObservedSample >> count [

	^ count
]

{ #category : #accessing }
MWObservedSample >> count: anObject [

	count := anObject
]

{ #category : #accessing }
MWObservedSample >> duration [

	^ duration
]

{ #category : #accessing }
MWObservedSample >> duration: anObject [

	duration := anObject
]

{ #category : #accessing }
MWObservedSample >> durationAvg [

	^ durationAvg
]

{ #category : #accessing }
MWObservedSample >> durationAvg: anObject [

	durationAvg := anObject
]

{ #category : #accessing }
MWObservedSample >> durationStDev [

	^ durationStDev
]

{ #category : #accessing }
MWObservedSample >> durationStDev: anObject [

	durationStDev := anObject
]

{ #category : #accessing }
MWObservedSample >> receivers [

	^ receivers
]

{ #category : #accessing }
MWObservedSample >> receivers: anObject [

	receivers := anObject
]
