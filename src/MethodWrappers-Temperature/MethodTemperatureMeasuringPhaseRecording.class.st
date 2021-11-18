"
I am a variant that encodes behavior and switching for the recording phase.
"
Class {
	#name : #MethodTemperatureMeasuringPhaseRecording,
	#superclass : #MethodTemperatureMeasuringPhase,
	#category : #'MethodWrappers-Temperature'
}

{ #category : #operations }
MethodTemperatureMeasuringPhaseRecording >> refreshInterval [

	^ 100 milliSeconds
]

{ #category : #operations }
MethodTemperatureMeasuringPhaseRecording >> runMeasureMethodsTemperaturesStCommand: aCommand forMethodsTemperaturesPresenter: aPresenter [

	aPresenter methodTemperatureWrappersDo: [ :each | each enable ].
	process := [ aPresenter updateVisualizations ] valueWithInterval:
		           self refreshInterval.
	aPresenter measureTemperaturesSpButtonPresenter
		badge: 'rec';
		update
]

{ #category : #operations }
MethodTemperatureMeasuringPhaseRecording >> toggle [

	^ MethodTemperatureMeasuringPhase sleeping
		  process: process;
		  yourself
]
