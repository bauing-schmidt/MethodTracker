Class {
	#name : #MWObservedData,
	#superclass : #Object,
	#instVars : [
		'tree',
		'metadata',
		'statistics'
	],
	#category : #MethodWrappers
}

{ #category : #accessing }
MWObservedData >> metadata [

	^ metadata
]

{ #category : #accessing }
MWObservedData >> metadata: anObject [

	metadata := anObject
]

{ #category : #accessing }
MWObservedData >> statistics [

	^ statistics
]

{ #category : #accessing }
MWObservedData >> statistics: anObject [

	statistics := anObject
]

{ #category : #accessing }
MWObservedData >> tree [

	^ tree
]

{ #category : #accessing }
MWObservedData >> tree: anObject [

	tree := anObject
]
