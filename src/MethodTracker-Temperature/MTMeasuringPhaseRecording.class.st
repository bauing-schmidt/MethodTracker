"
I am a variant that encodes behavior and switching for the recording phase.
"
Class {
	#name : #MTMeasuringPhaseRecording,
	#superclass : #MTMeasuringPhase,
	#category : #'MethodTracker-Temperature'
}

{ #category : #operations }
MTMeasuringPhaseRecording >> refreshInterval [

	^ 100 milliSeconds
]

{ #category : #operations }
MTMeasuringPhaseRecording >> runMeasureMethodsTemperaturesStCommand: aCommand forMethodsTemperaturesPresenter: aPresenter [

	aPresenter methodTemperatureWrappersDo: [ :each | each enable ].
	process := [ aPresenter updateVisualizations ] valueWithInterval:
		           self refreshInterval.
	aPresenter measureTemperaturesSpButtonPresenter
		badge: 'rec';
		update
]

{ #category : #operations }
MTMeasuringPhaseRecording >> toggle [

	^ MTMeasuringPhase sleeping
		  process: process;
		  yourself
]
