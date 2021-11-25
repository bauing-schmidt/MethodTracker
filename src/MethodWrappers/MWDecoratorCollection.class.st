Class {
	#name : #MWDecoratorCollection,
	#superclass : #OrderedCollection,
	#instVars : [
		'stackJust'
	],
	#category : #MethodWrappers
}

{ #category : #API }
MWDecoratorCollection class >> compiledMethods: aCollection thenSelect: methodBlock [

	| excludingClasses methods newCollection |
	excludingClasses := MWDecorator withAllSubclasses asSet.

	methods := aCollection select: [ :aMethod | 
		           (excludingClasses includes: aMethod methodClass) not 
			           and: [ methodBlock value: aMethod ] ].

	newCollection := self new.

	methods do: [ :each | 
		| decorator |
		decorator := MWDecorator new
			             compiledMethod: each;
			             yourself.

		newCollection add: decorator ].

	^ newCollection
]

{ #category : #API }
MWDecoratorCollection class >> forBaselineClass: aBaselineClass selectMethod: methodBlock [

	| methods |
	methods := (aBaselineClass allPackageNames collect: [ :each | 
		            each asPackage ]) flatCollect: [ :each | each methods ].

	^ self compiledMethods: methods thenSelect: methodBlock
]

{ #category : #API }
MWDecoratorCollection class >> forPackages: aCollection selectMethod: methodBlock [

	| methods |
	methods := aCollection asOrderedCollection flatCollect: [ :each | 
		           each methods ].

	^ self compiledMethods: methods thenSelect: methodBlock
]

{ #category : #'instance creation' }
MWDecoratorCollection class >> new [

	^ super new
		  owner: (Maybe just: nil);
		  yourself
]

{ #category : #'instance creation' }
MWDecoratorCollection class >> with: aWrapper [

	^ self withAll: { aWrapper }
]

{ #category : #'instance creation' }
MWDecoratorCollection class >> withAll: aCollection [

	^ self compiledMethods: aCollection thenSelect: [ :each | true ]
]

{ #category : #'instance creation' }
MWDecoratorCollection class >> withAllImplementations: aCollection [

	^ self
		  compiledMethods:
		  (aCollection flatCollect: [ :each | each overriddenMethods ])
		  thenSelect: [ :each | true ]
]

{ #category : #initialization }
MWDecoratorCollection >> add: aWrapper [

	aWrapper owner: stackJust.

	^ super add: aWrapper
]

{ #category : #accessing }
MWDecoratorCollection >> owner: aJust [

	stackJust := aJust
]
