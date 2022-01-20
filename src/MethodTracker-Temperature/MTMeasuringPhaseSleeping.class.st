"
I am a variant that encodes behavior and switching for the sleeping phase.
"
Class {
	#name : #MTMeasuringPhaseSleeping,
	#superclass : #MTMeasuringPhase,
	#category : #'MethodTracker-Temperature'
}

{ #category : #operations }
MTMeasuringPhaseSleeping >> runMeasureMethodsTemperaturesStCommand: aCommand forMethodsTemperaturesPresenter: aPresenter [

	aPresenter methodTemperatureWrappersDo: [ :each | each disable ].
	process terminate.
	aPresenter measureTemperaturesSpButtonPresenter
		badge: nil;
		update
]

{ #category : #operations }
MTMeasuringPhaseSleeping >> toggle [

	^ MTMeasuringPhase recording
		  process: process;
		  yourself
]
