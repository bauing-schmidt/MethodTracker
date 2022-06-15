"
I am a small data object to support the rendering of the heatmap.
"
Class {
	#name : #MTTemperatureData,
	#superclass : #Object,
	#instVars : [
		'method',
		'count'
	],
	#category : #'MethodTracker-Temperature-UI'
}

{ #category : #accessing }
MTTemperatureData >> count [

	^ count
]

{ #category : #accessing }
MTTemperatureData >> count: anObject [

	count := anObject
]

{ #category : #accessing }
MTTemperatureData >> method [

	^ method
]

{ #category : #accessing }
MTTemperatureData >> method: anObject [

	method := anObject
]
