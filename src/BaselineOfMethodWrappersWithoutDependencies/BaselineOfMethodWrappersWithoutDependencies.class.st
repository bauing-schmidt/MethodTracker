Class {
	#name : #BaselineOfMethodWrappersWithoutDependencies,
	#superclass : #BaselineOf,
	#category : #BaselineOfMethodWrappersWithoutDependencies
}

{ #category : #baselines }
BaselineOfMethodWrappersWithoutDependencies >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		self ownPackages: spec ]
]

{ #category : #baselines }
BaselineOfMethodWrappersWithoutDependencies >> ownPackages: spec [

	spec
		package: 'MethodWrappers';
		package: 'MethodWrappers-UI';
		package: 'MethodWrappers-Temperature';
		package: 'MethodWrappers-Temperature-UI';
		package: 'MethodWrappers-Tests'
]
