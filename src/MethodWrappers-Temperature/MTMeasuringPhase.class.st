"
I am a class that encodes phases about the measuring of methods' temperatures.
"
Class {
	#name : #MTMeasuringPhase,
	#superclass : #Object,
	#instVars : [
		'process'
	],
	#category : #'MethodWrappers-Temperature'
}

{ #category : #creating }
MTMeasuringPhase class >> recording [

	                          ^ MTMeasuringPhaseRecording
		                            new
]

{ #category : #creating }
MTMeasuringPhase class >> sleeping [

	                          ^ MTMeasuringPhaseSleeping
		                            new
]

{ #category : #accessing }
MTMeasuringPhase >> process: aProcess [

	process := aProcess
]

{ #category : #running }
MTMeasuringPhase >> runMeasureMethodsTemperaturesStCommand: aCommand forMethodsTemperaturesPresenter: aPresenter [

	self subclassResponsibility
]

{ #category : #running }
MTMeasuringPhase >> toggle [

	self subclassResponsibility
]
