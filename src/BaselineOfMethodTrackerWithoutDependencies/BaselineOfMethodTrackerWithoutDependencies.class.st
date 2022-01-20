Class {
	#name : #BaselineOfMethodTrackerWithoutDependencies,
	#superclass : #BaselineOf,
	#category : #BaselineOfMethodTrackerWithoutDependencies
}

{ #category : #baselines }
BaselineOfMethodTrackerWithoutDependencies >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		self ownPackages: spec ]
]

{ #category : #baselines }
BaselineOfMethodTrackerWithoutDependencies >> ownPackages: spec [

	spec
		package: 'MethodTracker';
		package: 'MethodTracker-UI';
		package: 'MethodTracker-Temperature';
		package: 'MethodTracker-Temperature-UI';
		package: 'MethodTracker-Tests'
]
