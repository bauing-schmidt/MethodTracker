Class {
	#name : #BaselineOfMethodWrappersMN,
	#superclass : #BaselineOf,
	#category : #BaselineOfMethodWrappersMN
}

{ #category : #baselines }
BaselineOfMethodWrappersMN >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		spec
			baseline: 'ContainersCategory'
			with: [ 
			spec repository: 'github://massimo-nocentini/Containers-Category' ].

		spec baseline: 'ContainersOrderPreservingTree' with: [ 
			spec repository:
				'github://massimo-nocentini/Containers-OrderPreservingTree' ].

		spec
			package: 'MethodWrappers';
			package: 'MethodWrappers-UI';
			package: 'MethodWrappers-Temperature';
			package: 'MethodWrappers-Temperature-UI';
			package: 'MethodWrappers-Tests';
			package: 'MethodWrappers-Tests-Visualizations' ]
]
