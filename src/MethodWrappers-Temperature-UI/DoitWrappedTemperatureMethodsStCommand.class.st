Class {
	#name : #DoitWrappedTemperatureMethodsStCommand,
	#superclass : #MethodsTemperaturesStCommand,
	#category : #'MethodWrappers-Temperature-UI'
}

{ #category : #default }
DoitWrappedTemperatureMethodsStCommand class >> defaultDescription [

	^ 'Do it.'
]

{ #category : #default }
DoitWrappedTemperatureMethodsStCommand class >> defaultIconName [

	^ #smallDoIt
]

{ #category : #default }
DoitWrappedTemperatureMethodsStCommand class >> defaultName [

	^ 'Doit'
]

{ #category : #default }
DoitWrappedTemperatureMethodsStCommand class >> priority [

	^ 300
]

{ #category : #execution }
DoitWrappedTemperatureMethodsStCommand >> execute [

	context runDoitWrappedTemperatureMethodsStCommand: self
]
