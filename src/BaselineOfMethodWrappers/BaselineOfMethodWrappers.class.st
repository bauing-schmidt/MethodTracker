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
		self roassal3Heatmap: spec.
		self ownPackages: spec ]
]

{ #category : #baselines }
BaselineOfMethodWrappers >> ownPackages: spec [

	spec
		package: 'MethodWrappers';
		package: 'MethodWrappers-UI';
		package: 'MethodWrappers-Temperature';
		package: 'MethodWrappers-Temperature-UI';
		package: 'MethodWrappers-Tests'
]

{ #category : #baselines }
BaselineOfMethodWrappers >> roassal3Heatmap: spec [

	spec package: 'Roassal3-Heatmap'
		with: [ 
			spec repository: 'github://bauing-schmidt/Roassal3:production10/src' ]
]

{ #category : #baselines }
BaselineOfMethodWrappers >> schmidtExtensions: spec [

	spec 
		baseline: 'SchmidtExtensions' 
		with: [ spec repository: 'github://bauing-schmidt/SchmidtExtensions:master/src' ]

]
