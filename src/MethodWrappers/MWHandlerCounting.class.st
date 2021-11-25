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
	#name : #MWHandlerCounting,
	#superclass : #MWHandler,
	#instVars : [
		'count'
	],
	#category : #MethodWrappers
}

{ #category : #accessing }
MWHandlerCounting >> count [ 

	^ count
]

{ #category : #initialization }
MWHandlerCounting >> initialize [

	super initialize.

	count := 0
]

{ #category : #evaluation }
MWHandlerCounting >> run: aSelector with: anArray in: aReceiver pre: aContext wrapper: aWrapper [

	aWrapper
		withSuspendWrapping: [ count := count add: 1 ]
		context: aContext.

	^ super
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  pre: aContext
		  wrapper: aWrapper
]
