Class {
	#name : #ConfSaveTemperatureMethodsStCommand,
	#superclass : #MethodsTemperaturesStCommand,
	#category : #'MethodWrappers-Temperature-UI'
}

{ #category : #default }
ConfSaveTemperatureMethodsStCommand class >> defaultDescription [

	^ 'Save conf.'
]

{ #category : #default }
ConfSaveTemperatureMethodsStCommand class >> defaultIconName [

	^ #smallSave
]

{ #category : #default }
ConfSaveTemperatureMethodsStCommand class >> defaultName [

	^ 'Save'
]

{ #category : #default }
ConfSaveTemperatureMethodsStCommand class >> priority [

	^ 500
]

{ #category : #execution }
ConfSaveTemperatureMethodsStCommand >> execute [

	context runConfSaveTemperatureMethodsStCommand: self
]
