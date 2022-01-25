Class {
	#name : #MTStCommandDoitWrapped,
	#superclass : #MTStCommand,
	#category : #'MethodTracker-Temperature-UI'
}

{ #category : #default }
MTStCommandDoitWrapped class >> defaultDescription [

	^ 'Do it.'
]

{ #category : #default }
MTStCommandDoitWrapped class >> defaultIconName [

	^ #smallDoIt
]

{ #category : #default }
MTStCommandDoitWrapped class >> defaultName [

	^ 'Doit'
]

{ #category : #default }
MTStCommandDoitWrapped class >> priority [

	^ 300
]

{ #category : #execution }
MTStCommandDoitWrapped >> execute [

	context runDoitWrappedTemperatureMethodsStCommand: self
]
