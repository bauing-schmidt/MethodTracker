Class {
	#name : #BaselineOfMethodWrappers,
	#superclass : #BaselineOf,
	#category : #BaselineOfMethodWrappers
}

{ #category : #baselines }
BaselineOfMethodWrappers >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		
		self schmidtExtensions: spec.
		
		spec
			package: 'MethodWrappers';
			package: 'MethodWrappers-UI';
			package: 'Roassal3-Heatmap'
			with: [ 
				spec repository: 'github://bauing-schmidt/Roassal3:production10/src' ];
			package: 'MethodWrappers-Temperature';
			package: 'MethodWrappers-Temperature-UI' ]
]

{ #category : #baselines }
BaselineOfMethodWrappers >> schmidtExtensions: spec [

	spec 
		baseline: 'SchmidtExtensions' 
		with: [ spec repository: 'github://bauing-schmidt/SchmidtExtensions:master/src' ]

]
