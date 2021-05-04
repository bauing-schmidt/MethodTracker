Class {
	#name : #BaselineOfMethodWrappers,
	#superclass : #BaselineOf,
	#category : #BaselineOfMethodWrappers
}

{ #category : #baselines }
BaselineOfMethodWrappers >> baseline: spec [

	  <baseline>
	  spec for: #common do: [ 
		  spec
			  package: 'MethodWrappers';
			  package: 'MethodWrappers-UI';
			  package: 'Roassal3-Heatmap';
			  package: 'MethodWrappers-Temperature';
			  package: 'MethodWrappers-Temperature-UI' ]
]
