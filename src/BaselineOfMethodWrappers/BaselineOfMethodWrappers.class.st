Class {
	#name : #BaselineOfMethodWrappers,
	#superclass : #BaselineOf,
	#category : #BaselineOfMethodWrappers
}

{ #category : #baselines }
BaselineOfMethodWrappers >> baseline: spec [

	  <baseline>
	  spec
		  for: #common
		  do: [ "For the dependency on RSHeatmap, have a look at the 
			      corresponding repo loaded in BaselineOfIDE>>#baseline:"
			  spec
				  package: 'MethodWrappers';
				  package: 'MethodWrappers-UI';
				  package: 'Roassal3-Heatmap'
				  with: [ 
					  spec repository: 'github://ObjectProfile/Roassal3:v0.9.7b/src' ];
				  package: 'MethodWrappers-Temperature';
				  package: 'MethodWrappers-Temperature-UI' ]
]
