Class {
	#name : #MTStCommandMeasure,
	#superclass : #MTStCommand,
	#category : #'MethodTracker-Temperature-UI'
}

{ #category : #default }
MTStCommandMeasure class >> defaultDescription [

	^ 'Measure temperature of compiled methods after the evaluation of the `do` block.'
]

{ #category : #accessing }
MTStCommandMeasure class >> defaultIconName [

	^ #smallProfile
]

{ #category : #default }
MTStCommandMeasure class >> defaultName [

	^ 'Measure temps'
]

{ #category : #accessing }
MTStCommandMeasure class >> priority [

	^ 200
]

{ #category : #executing }
MTStCommandMeasure >> execute [

	context runMeasureMethodsTemperaturesStCommand: self
]
