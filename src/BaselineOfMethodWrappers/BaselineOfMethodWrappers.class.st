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
			package: 'Roassal3-Heatmap'
			with: [ 
				spec repository: 'github://bauing-schmidt/Roassal3:production/src' ];
			"package: 'Roassal3-Spec-Morphic';"
			package: 'MethodWrappers-Temperature';
			package: 'MethodWrappers-Temperature-UI' ]
]
