Class {
	#name : #BaselineOfMethodTrackerMN,
	#superclass : #BaselineOf,
	#category : #BaselineOfMethodTrackerMN
}

{ #category : #baselines }
BaselineOfMethodTrackerMN >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		spec
			baseline: 'ContainersEssentials'
			with: [ 
			spec repository: 'github://massimo-nocentini/Containers-Essentials' ].

		spec
			baseline: 'ContainersCategory'
			with: [ 
			spec repository: 'github://massimo-nocentini/Containers-Category' ].

		spec baseline: 'ContainersOrderPreservingTree' with: [ 
			spec repository:
				'github://massimo-nocentini/Containers-OrderPreservingTree' ].

		spec
			package: 'MethodTracker';
			package: 'MethodTracker-UI';
			package: 'MethodTracker-Temperature';
			package: 'MethodTracker-Temperature-UI';
			package: 'MethodTracker-Tests';
			package: 'MethodTracker-Visualizations' ]
]
