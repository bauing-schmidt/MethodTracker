Class {
	#name : #InstallMethodTemperatureWrappersStCommand,
	#superclass : #MethodsTemperaturesStCommand,
	#category : #'MethodWrappers-Temperature-UI'
}

{ #category : #accessing }
InstallMethodTemperatureWrappersStCommand class >> defaultDescription [

	^ 'Install method temperature wrappers.'
]

{ #category : #accessing }
InstallMethodTemperatureWrappersStCommand class >> defaultIconName [

	^ #smallDoIt
]

{ #category : #accessing }
InstallMethodTemperatureWrappersStCommand class >> defaultName [

	^ 'Install wrappers'
]

{ #category : #accessing }
InstallMethodTemperatureWrappersStCommand class >> priority [ 

	^ 100
]

{ #category : #executing }
InstallMethodTemperatureWrappersStCommand >> execute [

	context runInstallMethodTemperatureWrappersStCommand: self
]
