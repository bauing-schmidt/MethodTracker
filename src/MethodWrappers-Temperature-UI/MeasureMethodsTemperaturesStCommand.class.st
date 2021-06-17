Class {
	#name : #MeasureMethodsTemperaturesStCommand,
	#superclass : #MethodsTemperaturesStCommand,
	#category : #'MethodWrappers-Temperature-UI'
}

{ #category : #default }
MeasureMethodsTemperaturesStCommand class >> defaultDescription [

	^ 'Measure temperature of compiled methods after the evaluation of the `do` block.'
]

{ #category : #accessing }
MeasureMethodsTemperaturesStCommand class >> defaultIconName [

	^ #smallProfile
]

{ #category : #default }
MeasureMethodsTemperaturesStCommand class >> defaultName [

	^ 'Measure temps'
]

{ #category : #accessing }
MeasureMethodsTemperaturesStCommand class >> priority [

	^ 200
]

{ #category : #executing }
MeasureMethodsTemperaturesStCommand >> execute [

	context runMeasureMethodsTemperaturesStCommand: self
]
