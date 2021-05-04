"
I am a class that encodes phases about the measuring of methods' temperatures.
"
Class {
	#name : #MethodTemperatureMeasuringPhase,
	#superclass : #Object,
	#instVars : [
		'process'
	],
	#category : #'MethodWrappers-Temperature'
}

{ #category : #creating }
MethodTemperatureMeasuringPhase class >> recording [

	                          ^ MethodTemperatureMeasuringPhaseRecording
		                            new
]

{ #category : #creating }
MethodTemperatureMeasuringPhase class >> sleeping [

	                          ^ MethodTemperatureMeasuringPhaseSleeping
		                            new
]

{ #category : #accessing }
MethodTemperatureMeasuringPhase >> process: aProcess [

	process := aProcess
]

{ #category : #running }
MethodTemperatureMeasuringPhase >> runMeasureMethodsTemperaturesStCommand: aCommand forMethodsTemperaturesPresenter: aPresenter [

	self subclassResponsibility
]

{ #category : #running }
MethodTemperatureMeasuringPhase >> toggle [

	self subclassResponsibility
]
