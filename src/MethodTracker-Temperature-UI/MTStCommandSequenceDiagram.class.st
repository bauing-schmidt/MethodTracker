Class {
	#name : #MTStCommandSequenceDiagram,
	#superclass : #MTStCommand,
	#category : #'MethodTracker-Temperature-UI'
}

{ #category : #default }
MTStCommandSequenceDiagram class >> defaultDescription [

	^ 'Build sequence diagrams according to the recorded interactions.'
]

{ #category : #default }
MTStCommandSequenceDiagram class >> defaultIconName [

	^ #smallProfile
]

{ #category : #default }
MTStCommandSequenceDiagram class >> defaultName [

	^ 'Sequence diagrams'
]

{ #category : #default }
MTStCommandSequenceDiagram class >> priority [

	^ 500
]

{ #category : #execution }
MTStCommandSequenceDiagram >> execute [

	context runSequenceDiagramMethodsTemperaturesStCommand: self
]
