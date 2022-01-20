Class {
	#name : #MTStCommandConfSave,
	#superclass : #MTStCommand,
	#category : #'MethodWrappers-Temperature-UI'
}

{ #category : #default }
MTStCommandConfSave class >> defaultDescription [

	^ 'Save conf.'
]

{ #category : #default }
MTStCommandConfSave class >> defaultIconName [

	^ #smallSave
]

{ #category : #default }
MTStCommandConfSave class >> defaultName [

	^ 'Save'
]

{ #category : #default }
MTStCommandConfSave class >> priority [

	^ 500
]

{ #category : #execution }
MTStCommandConfSave >> execute [

	context runConfSaveTemperatureMethodsStCommand: self
]
