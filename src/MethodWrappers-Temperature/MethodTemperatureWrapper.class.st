"
```
methods := (BaselineOfDocumaps allPackageNames collect: [ :each | each asPackage ]) flatCollect: [ :each | each methods ].

wrappers := methods collect: [ :each | MethodTemperatureWrapper on: each ].
wrappers do: [ :each | each install ].

""open the application here ""
    
wrappers do: [ :each | each uninstall ].
wrappers := (wrappers sorted: [:a :b | a count <= b count]) collect: [:e | e count -> e].

""find one method""

wrappers detect: [ :e |  e value method = (PdmStandardNames>>#getOwnPersonIdForUserName:) ]
```
"
Class {
	#name : #MethodTemperatureWrapper,
	#superclass : #AbstractMethodWrapper,
	#instVars : [
		'count'
	],
	#category : #'MethodWrappers-Temperature'
}

{ #category : #accessing }
MethodTemperatureWrapper >> count [ 

	^ count
]

{ #category : #initialization }
MethodTemperatureWrapper >> initializeOn: aMethodReference [

	count := 0.

	^ super initializeOn: aMethodReference
]

{ #category : #evaluation }
MethodTemperatureWrapper >> run: aSelector with: anArray in: aReceiver pre: aContext [

	super
		run: aSelector
		with: anArray
		in: aReceiver
		pre: aContext.

	count := count + 1
]
