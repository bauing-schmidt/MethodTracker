"
I am a variant that encodes behavior and switching for the sleeping phase.
"
Class {
	#name : #MethodTemperatureMeasuringPhaseSleeping,
	#superclass : #MethodTemperatureMeasuringPhase,
	#category : #'MethodWrappers-Temperature'
}

{ #category : #operations }
MethodTemperatureMeasuringPhaseSleeping >> runMeasureMethodsTemperaturesStCommand: aCommand forMethodsTemperaturesPresenter: aPresenter [

	aPresenter methodTemperatureWrappersDo: [ :each | each disable ].
	process terminate.
	aPresenter measureTemperaturesSpButtonPresenter
		badge: nil;
		update
]

{ #category : #operations }
MethodTemperatureMeasuringPhaseSleeping >> toggle [

	^ MethodTemperatureMeasuringPhase recording
		  process: process;
		  yourself
]
