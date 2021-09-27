Class {
	#name : #ConfLoadTemperatureMethodsStCommand,
	#superclass : #MethodsTemperaturesStCommand,
	#category : #'MethodWrappers-Temperature-UI'
}

{ #category : #default }
ConfLoadTemperatureMethodsStCommand class >> defaultDescription [

	^ 'Load conf.'
]

{ #category : #default }
ConfLoadTemperatureMethodsStCommand class >> defaultIconName [

	^ #smallConfigurationIcon
]

{ #category : #default }
ConfLoadTemperatureMethodsStCommand class >> defaultName [

	^ 'Load'
]

{ #category : #default }
ConfLoadTemperatureMethodsStCommand class >> priority [

	^ 400
]

{ #category : #execution }
ConfLoadTemperatureMethodsStCommand >> execute [

	context runConfLoadTemperatureMethodsStCommand: self
]
