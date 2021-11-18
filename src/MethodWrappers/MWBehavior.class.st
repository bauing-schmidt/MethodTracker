"
I am an abstract class that install a wrapper around a compiled method, and uninstall it when finished my scope.
"
Class {
	#name : #MWBehavior,
	#superclass : #Object,
	#instVars : [
		'compiledMethod',
		'handler',
		'selector',
		'methodClass'
	],
	#category : #MethodWrappers
}

{ #category : #'instance creation' }
MWBehavior class >> behavior: aBehavior selector: aSelector [

	^ self basicNew
		  methodClass: aBehavior;
		  selector: aSelector;
		  initialize;
		  yourself
]

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

	^ self
		  behavior: aCompiledMethod methodClass
		  selector: aCompiledMethod selector
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

{ #category : #dispatched }
MWBehavior >> compiledMethod: aCompiledMethod [

	| dict |
	compiledMethod := aCompiledMethod.

	"methodClass addSelectorSilently: selector withMethod: compiledMethod"
	dict := compiledMethod methodClass methodDict
		        at: compiledMethod selector put: self;
		        rehash;
		        yourself
]

{ #category : #private }
MWBehavior >> doesNotUnderstand: aMessage [

	^ self
		  ifInstalled: [ 
			  compiledMethod
				  perform: aMessage selector
				  withArguments: aMessage arguments ]
		  ifNotInstalled: [ super doesNotUnderstand: aMessage ]
]

{ #category : #accessing }
MWBehavior >> handler: anObject [

	handler := anObject
]

{ #category : #private }
MWBehavior >> ifInstalled: iBlock ifNotInstalled: niBlock [

	^ compiledMethod ifNil: niBlock ifNotNil: iBlock
]

{ #category : #actions }
MWBehavior >> install [

	self
		ifInstalled: [ Warning signal: 'Already installed wrapper.' ]
		ifNotInstalled: [ 
			(methodClass lookupSelector: selector) ifNotNil: [ :aMethodOrWrapper | 
				aMethodOrWrapper installOnMethodWrapper: self ] ]
]

{ #category : #dispatched }
MWBehavior >> installOnMethodWrapper: aWrapper [

	Warning signal: 'Attempting to wrap a wrapper'
]

{ #category : #testing }
MWBehavior >> isCompiledMethod [

	^ false
]

{ #category : #testing }
MWBehavior >> isMethodWrapper [

	^ true
]

{ #category : #accessing }
MWBehavior >> methodClass: anObject [

	methodClass := anObject
]

{ #category : #printing }
MWBehavior >> printOn: aStream [

	aStream nextPutAll: '[ '.

	self
		ifInstalled: [ compiledMethod printOn: aStream ]
		ifNotInstalled: [ 
			aStream
				print: methodClass;
				nextPutAll: ' • ';
				print: selector ].

	aStream nextPutAll: ' ] π'
]

{ #category : #evaluation }
MWBehavior >> run: aSelector with: anArray in: aReceiver [

	^ aSelector = compiledMethod selector
		  ifTrue: [ 
			  | carry result witness aContext |
			  aContext := thisContext.

			  witness := Object new.

			  carry := handler ifNil: [ witness ] ifNotNil: [ 
				           handler
					           run: aSelector
					           with: anArray
					           in: aReceiver
					           pre: aContext ].

			  result := aReceiver
				            withArgs: anArray
				            executeMethod: compiledMethod.

			  carry == witness ifFalse: [ 
				  handler
					  run: aSelector
					  with: anArray
					  in: aReceiver
					  post: aContext
					  return: result
					  carry: carry ].

			  ^ result ]
		  ifFalse: [ 
			  Error signal:
				  'Attempt to send a selector that is different from the compiledMethod''s one.' ]
]

{ #category : #accessing }
MWBehavior >> selector: anObject [

	selector := anObject
]

{ #category : #actions }
MWBehavior >> uninstall [

	self
		ifInstalled: [ 
			compiledMethod methodClass methodDict
				at: compiledMethod selector
				put: compiledMethod.

			compiledMethod := nil ]
		ifNotInstalled: [ 
		Warning signal: 'Attempted to uninstall a not installed wrapper.' ]
]
