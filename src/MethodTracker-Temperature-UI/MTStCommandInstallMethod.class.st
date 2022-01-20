Class {
	#name : #MTStCommandInstallMethod,
	#superclass : #MTStCommand,
	#category : #'MethodTracker-Temperature-UI'
}

{ #category : #accessing }
MTStCommandInstallMethod class >> defaultDescription [

	^ 'Install method temperature wrappers.'
]

{ #category : #accessing }
MTStCommandInstallMethod class >> defaultIconName [

	^ #add
]

{ #category : #accessing }
MTStCommandInstallMethod class >> defaultName [

	^ 'Wrap & Do'
]

{ #category : #accessing }
MTStCommandInstallMethod class >> priority [ 

	^ 100
]

{ #category : #executing }
MTStCommandInstallMethod >> execute [

	context runInstallMethodTemperatureWrappersStCommand: self
]
