"
I am an abstract class that install a wrapper around a compiled method, and uninstall it when finished my scope.
"
Class {
	#name : #MWDecorator,
	#superclass : #Object,
	#instVars : [
		'compiledMethod',
		'handler'
	],
	#category : #MethodWrappers
}

{ #category : #API }
MWDecorator class >> compiledMethods: aCollection thenSelect: methodBlock [

	| excludingClasses methods |
	excludingClasses := MWDecorator withAllSubclasses asSet.

	methods := aCollection select: [ :aMethod | 
		           (excludingClasses includes: aMethod methodClass) not 
			           and: [ methodBlock value: aMethod ] ].

	^ methods collect: [ :each | self on: each ]
]

{ #category : #initialization }
MWDecorator class >> doInspectAllInstances [

	<script>
	MWDecorator inspectAllInstances
]

{ #category : #API }
MWDecorator class >> forBaselineClass: aBaselineClass selectMethod: methodBlock [

	| methods |
	methods := (aBaselineClass allPackageNames collect: [ :each | 
		            each asPackage ]) flatCollect: [ :each | each methods ].

	^ self compiledMethods: methods thenSelect: methodBlock
]

{ #category : #API }
MWDecorator class >> forPackages: aCollection selectMethod: methodBlock [

	| methods |
	methods := aCollection asOrderedCollection flatCollect: [ :each | 
		           each methods ].

	^ self compiledMethods: methods thenSelect: methodBlock
]

{ #category : #'instance creation' }
MWDecorator class >> on: aCompiledMethod [

	^ self new
		  compiledMethod: aCompiledMethod;
		  yourself
]

{ #category : #initialization }
MWDecorator class >> reset [

	<script>
	MWDecorator allSubclassesDo: [ :each | 
		each allInstances do: [ :w | 
			[ w uninstall ] onDNU: #uninstall do: [  ] ] ].
	SpNullApplication reset.
	Smalltalk garbageCollect
]

{ #category : #'instance creation' }
MWDecorator class >> withAll: aCollection [

	^ self compiledMethods: aCollection thenSelect: [ :each | true ]
]

{ #category : #'instance creation' }
MWDecorator class >> withAllImplementations: aCollection [

	^ self
		  compiledMethods:
		  (aCollection flatCollect: [ :each | each allImplementations ])
		  thenSelect: [ :each | true ]
]

{ #category : #initialization }
MWDecorator >> compiledMethod: aCompiledMethod [

	compiledMethod := aCompiledMethod
]

{ #category : #private }
MWDecorator >> doesNotUnderstand: aMessage [

	^ compiledMethod
		  perform: aMessage selector
		  withArguments: aMessage arguments
]

{ #category : #accessing }
MWDecorator >> handler: anObject [

	handler := anObject
]

{ #category : #private }
MWDecorator >> ifInstalled: iBlock ifNotInstalled: niBlock [

	^ compiledMethod methodClass methodDict
		  at: compiledMethod selector
		  ifPresent: [ :aMethod | 
			  aMethod == self
				  ifTrue: iBlock
				  ifFalse: niBlock ]
		  ifAbsent: [ Error signal ]
]

{ #category : #actions }
MWDecorator >> install [

	self
		ifInstalled: [ Warning signal: 'Already installed wrapper.' ]
		ifNotInstalled: [ self put: self ]
]

{ #category : #testing }
MWDecorator >> isMethodWrapper [

	^ true
]

{ #category : #printing }
MWDecorator >> printOn: aStream [

	aStream nextPutAll: '[ '.

	self
		ifInstalled: [ compiledMethod printOn: aStream ]
		ifNotInstalled: [ 
			aStream
				print: compiledMethod methodClass;
				nextPutAll: ' • ';
				print: compiledMethod selector ].

	aStream nextPutAll: ' ] π'
]

{ #category : #actions }
MWDecorator >> put: aMethod [

	compiledMethod methodClass methodDict
		at: compiledMethod selector put: aMethod;
		rehash
]

{ #category : #evaluation }
MWDecorator >> run: aSelector with: anArray in: aReceiver [

	| aContext |
	self assert: aSelector = compiledMethod selector.

	aContext := thisContext sender.

	^ handler
		  ifNil: [ self valueWithReceiver: aReceiver arguments: anArray ]
		  ifNotNil: [ 
			  handler
				  run: aSelector
				  with: anArray
				  in: aReceiver
				  context: aContext
				  wrapper: self ]
]

{ #category : #actions }
MWDecorator >> uninstall [

	self
		ifInstalled: [ self put: compiledMethod ]
		ifNotInstalled: [ 
		Warning signal: 'Attempted to uninstall a not installed wrapper.' ]
]

{ #category : #evaluation }
MWDecorator >> valueWithReceiver: aReceiver arguments: anArray [

	^ aReceiver withArgs: anArray executeMethod: compiledMethod
]
