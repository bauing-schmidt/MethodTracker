Class {
	#name : #SequenceDiagramMethodsTemperaturesStCommand,
	#superclass : #MethodsTemperaturesStCommand,
	#category : #'MethodWrappers-Temperature-UI'
}

{ #category : #default }
SequenceDiagramMethodsTemperaturesStCommand class >> defaultDescription [

	^ 'Build sequence diagrams according to the recorded interactions.'
]

{ #category : #default }
SequenceDiagramMethodsTemperaturesStCommand class >> defaultIconName [

	^ #smallProfile
]

{ #category : #default }
SequenceDiagramMethodsTemperaturesStCommand class >> defaultName [

	^ 'Sequence diagrams'
]

{ #category : #default }
SequenceDiagramMethodsTemperaturesStCommand class >> priority [

	^ 500
]

{ #category : #execution }
SequenceDiagramMethodsTemperaturesStCommand >> execute [

	context runSequenceDiagramMethodsTemperaturesStCommand: self
]
