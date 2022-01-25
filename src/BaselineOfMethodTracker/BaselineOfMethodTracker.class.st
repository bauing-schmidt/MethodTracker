Class {
	#name : #BaselineOfMethodTracker,
	#superclass : #BaselineOf,
	#category : #BaselineOfMethodTracker
}

{ #category : #baselines }
BaselineOfMethodTracker >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		self schmidtExtensions: spec.
		self caotainersEssentials: spec.
		self roassal3Heatmap: spec.
		self ownPackages: spec ]
]

{ #category : #baselines }
BaselineOfMethodTracker >> caotainersEssentials: spec [

	spec 
		baseline: 'ContainersEssentials' 
		with: [ spec repository: 'github://bauing-schmidt/Containers-Essentials:master/src' ]

]

{ #category : #baselines }
BaselineOfMethodTracker >> ownPackages: spec [

	spec
		package: 'MethodTracker';
		package: 'MethodTracker-UI';
		package: 'MethodTracker-Temperature';
		package: 'MethodTracker-Temperature-UI';
		package: 'MethodTracker-Tests'
]

{ #category : #baselines }
BaselineOfMethodTracker >> roassal3Heatmap: spec [

	spec package: 'Roassal3-Heatmap'
		with: [ 
			spec repository: 'github://bauing-schmidt/Roassal3:production10/src' ]
]

{ #category : #baselines }
BaselineOfMethodTracker >> schmidtExtensions: spec [

	spec 
		baseline: 'SchmidtExtensions' 
		with: [ spec repository: 'github://bauing-schmidt/SchmidtExtensions:master/src' ]

]
