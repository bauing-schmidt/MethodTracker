Class {
	#name : #MTObservedDatarow,
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
MTObservedDatarow >> clients [

	^ clients
]

{ #category : #accessing }
MTObservedDatarow >> clients: anObject [

	clients := anObject
]

{ #category : #accessing }
MTObservedDatarow >> compiledMethod [

	^ compiledMethod
]

{ #category : #accessing }
MTObservedDatarow >> compiledMethod: anObject [

	compiledMethod := anObject
]

{ #category : #accessing }
MTObservedDatarow >> count [

	^ count
]

{ #category : #accessing }
MTObservedDatarow >> count: anObject [

	count := anObject
]

{ #category : #accessing }
MTObservedDatarow >> duration [

	^ duration
]

{ #category : #accessing }
MTObservedDatarow >> duration: anObject [

	duration := anObject
]

{ #category : #accessing }
MTObservedDatarow >> durationAvg [

	^ durationAvg
]

{ #category : #accessing }
MTObservedDatarow >> durationAvg: anObject [

	durationAvg := anObject
]

{ #category : #accessing }
MTObservedDatarow >> durationStDev [

	^ durationStDev
]

{ #category : #accessing }
MTObservedDatarow >> durationStDev: anObject [

	durationStDev := anObject
]

{ #category : #accessing }
MTObservedDatarow >> receivers [

	^ receivers
]

{ #category : #accessing }
MTObservedDatarow >> receivers: anObject [

	receivers := anObject
]
