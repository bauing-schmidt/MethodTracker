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
	#name : #MTHandlerCounting,
	#superclass : #MTHandlerPrePostPlugging,
	#instVars : [
		'count'
	],
	#category : #MethodWrappers
}

{ #category : #evaluation }
MTHandlerCounting >> add: a to: b [

	^ a addNumber: b
]

{ #category : #accessing }
MTHandlerCounting >> count [ 

	^ count
]

{ #category : #initialization }
MTHandlerCounting >> initialize [

	super initialize.

	count := 0
]

{ #category : #evaluation }
MTHandlerCounting >> run: aSelector with: anArray in: aReceiver preContext: aContext wrapper: aWrapper [

	count := self add: count to: 1
]
