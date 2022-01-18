Class {
	#name : #MWObservedDatarow,
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
MWObservedDatarow >> clients [

	^ clients
]

{ #category : #accessing }
MWObservedDatarow >> clients: anObject [

	clients := anObject
]

{ #category : #accessing }
MWObservedDatarow >> compiledMethod [

	^ compiledMethod
]

{ #category : #accessing }
MWObservedDatarow >> compiledMethod: anObject [

	compiledMethod := anObject
]

{ #category : #accessing }
MWObservedDatarow >> count [

	^ count
]

{ #category : #accessing }
MWObservedDatarow >> count: anObject [

	count := anObject
]

{ #category : #accessing }
MWObservedDatarow >> duration [

	^ duration
]

{ #category : #accessing }
MWObservedDatarow >> duration: anObject [

	duration := anObject
]

{ #category : #accessing }
MWObservedDatarow >> durationAvg [

	^ durationAvg
]

{ #category : #accessing }
MWObservedDatarow >> durationAvg: anObject [

	durationAvg := anObject
]

{ #category : #accessing }
MWObservedDatarow >> durationStDev [

	^ durationStDev
]

{ #category : #accessing }
MWObservedDatarow >> durationStDev: anObject [

	durationStDev := anObject
]

{ #category : #accessing }
MWObservedDatarow >> receivers [

	^ receivers
]

{ #category : #accessing }
MWObservedDatarow >> receivers: anObject [

	receivers := anObject
]
