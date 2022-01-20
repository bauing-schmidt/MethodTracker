Class {
	#name : #MTStCommandConfLoad,
	#superclass : #MTStCommand,
	#category : #'MethodTracker-Temperature-UI'
}

{ #category : #default }
MTStCommandConfLoad class >> defaultDescription [

	^ 'Load conf.'
]

{ #category : #default }
MTStCommandConfLoad class >> defaultIconName [

	^ #smallConfigurationIcon
]

{ #category : #default }
MTStCommandConfLoad class >> defaultName [

	^ 'Load'
]

{ #category : #default }
MTStCommandConfLoad class >> priority [

	^ 400
]

{ #category : #execution }
MTStCommandConfLoad >> execute [

	context runConfLoadTemperatureMethodsStCommand: self
]
