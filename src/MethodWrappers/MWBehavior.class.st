"
I am an abstract class that install a wrapper around a compiled method, and uninstall it when finished my scope.
"
Class {
	#name : #MWBehavior,
	#superclass : #Object,
	#instVars : [
		'compiledMethod',
		'handler'
	],
	#category : #MethodWrappers
}

{ #category : #API }
MWBehavior class >> compiledMethods: aCollection thenSelect: methodBlock [

	| excludingClasses |
	excludingClasses := MWBehavior withAllSubclasses asSet.

	^ aCollection
		  select: [ :aMethod | 
			  (excludingClasses includes: aMethod methodClass) not and: [ 
				  methodBlock value: aMethod ] ]
		  thenCollect: [ :each | self on: each ]
]

{ #category : #API }
MWBehavior class >> forBaselineClass: aBaselineClass selectMethod: methodBlock [

	| methods |
	methods := (aBaselineClass allPackageNames collect: [ :each | 
		            each asPackage ]) flatCollect: [ :each | each methods ].

	^ self compiledMethods: methods thenSelect: methodBlock
]

{ #category : #API }
MWBehavior class >> forPackages: aCollection selectMethod: methodBlock [

	| methods |
	methods := aCollection asOrderedCollection flatCollect: [ :each | 
		           each methods ].

	^ self compiledMethods: methods thenSelect: methodBlock
]

{ #category : #'instance creation' }
MWBehavior class >> on: aCompiledMethod [

	^ self new
		  compiledMethod: aCompiledMethod;
		  yourself
]

{ #category : #initialization }
MWBehavior class >> reset [

	<script>
	MWBehavior allSubclassesDo: [ :each | 
		each allInstances do: [ :w | 
			[ w uninstall ] onDNU: #uninstall do: [  ] ] ].
	SpNullApplication reset.
	Smalltalk garbageCollect
]

{ #category : #'instance creation' }
MWBehavior class >> withAll: aCollection [

	^ self compiledMethods: aCollection thenSelect: [ :each | true ]
]

{ #category : #'instance creation' }
MWBehavior class >> withAllImplementations: aCollection [

	^ self
		  compiledMethods:
		  (aCollection flatCollect: [ :each | each allImplementations ])
		  thenSelect: [ :each | true ]
]

{ #category : #initialization }
MWBehavior >> compiledMethod: aCompiledMethod [

	compiledMethod := aCompiledMethod
]

{ #category : #private }
MWBehavior >> doesNotUnderstand: aMessage [

	^ compiledMethod
		  perform: aMessage selector
		  withArguments: aMessage arguments
]

{ #category : #accessing }
MWBehavior >> handler: anObject [

	handler := anObject
]

{ #category : #private }
MWBehavior >> ifInstalled: iBlock ifNotInstalled: niBlock [

	^ compiledMethod methodClass methodDict
		  at: compiledMethod selector
		  ifPresent: [ :aMethod | 
			  aMethod == self
				  ifTrue: iBlock
				  ifFalse: niBlock ]
		  ifAbsent: [ Error signal ]
]

{ #category : #actions }
MWBehavior >> install [

	self
		ifInstalled: [ Warning signal: 'Already installed wrapper.' ]
		ifNotInstalled: [ self put: self ]
]

{ #category : #testing }
MWBehavior >> isMethodWrapper [

	^ true
]

{ #category : #printing }
MWBehavior >> printOn: aStream [

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
MWBehavior >> put: aMethod [

	compiledMethod methodClass methodDict
		at: compiledMethod selector put: aMethod;
		rehash
]

{ #category : #evaluation }
MWBehavior >> run: aSelector with: anArray in: aReceiver [

	| aContext |
	aContext := thisContext sender.

	aSelector = compiledMethod selector ifFalse: [ 
		Error signal:
			'Attempt to send a selector that is different from the compiledMethod''s one.' ].

	^ handler
		  ifNil: [ self value: aReceiver withArguments: anArray ]
		  ifNotNil: [ 
			  | carry result |
			  carry := handler
				           run: aSelector
				           with: anArray
				           in: aReceiver
				           pre: aContext.

			  result := handler
				            run: aSelector
				            with: anArray
				            in: aReceiver
				            context: aContext
				            carry: carry
				            wrapper: self.

			  handler
				  run: aSelector
				  with: anArray
				  in: aReceiver
				  post: aContext
				  return: result
				  carry: carry.

			  result ]
]

{ #category : #actions }
MWBehavior >> uninstall [

	self
		ifInstalled: [ self put: compiledMethod ]
		ifNotInstalled: [ 
		Warning signal: 'Attempted to uninstall a not installed wrapper.' ]
]

{ #category : #evaluation }
MWBehavior >> value: aReceiver withArguments: anArray [

	^ aReceiver withArgs: anArray executeMethod: compiledMethod
]
