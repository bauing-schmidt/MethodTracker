"
I am an abstract class that install a wrapper around a compiled method, and uninstall it when finished my scope.
"
Class {
	#name : #AbstractMethodWrapper,
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
AbstractMethodWrapper class >> behavior: aBehavior selector: aSelector [

	^ self basicNew
		  methodClass: aBehavior;
		  selector: aSelector;
		  initialize;
		  yourself
]

{ #category : #API }
AbstractMethodWrapper class >> compiledMethods: aCollection thenSelect: methodBlock [

	| excludingClasses |
	excludingClasses := AbstractMethodWrapper withAllSubclasses asSet.

	^ aCollection
		  select: [ :aMethod | 
			  (excludingClasses includes: aMethod methodClass) not and: [ 
				  methodBlock value: aMethod ] ]
		  thenCollect: [ :each | self on: each ]
]

{ #category : #API }
AbstractMethodWrapper class >> forBaselineClass: aBaselineClass selectMethod: methodBlock [

	| methods |
	methods := (aBaselineClass allPackageNames collect: [ :each | 
		            each asPackage ]) flatCollect: [ :each | each methods ].

	^ self compiledMethods: methods thenSelect: methodBlock
]

{ #category : #API }
AbstractMethodWrapper class >> forPackages: aCollection selectMethod: methodBlock [

	| methods |
	methods := aCollection asOrderedCollection flatCollect: [ :each | 
		           each methods ].

	^ self compiledMethods: methods thenSelect: methodBlock
]

{ #category : #'instance creation' }
AbstractMethodWrapper class >> on: aCompiledMethod [

	^ self
		  behavior: aCompiledMethod methodClass
		  selector: aCompiledMethod selector
]

{ #category : #initialization }
AbstractMethodWrapper class >> reset [

	<script>
	AbstractMethodWrapper allSubclassesDo: [ :each | 
		each allInstances do: [ :w | 
			[ w uninstall ] onDNU: #uninstall do: [  ] ] ].
	SpNullApplication reset.
	Smalltalk garbageCollect
]

{ #category : #'instance creation' }
AbstractMethodWrapper class >> withAll: aCollection [

	^ self compiledMethods: aCollection thenSelect: [ :each | true ]
]

{ #category : #'instance creation' }
AbstractMethodWrapper class >> withAllImplementations: aCollection [

	^ self
		  compiledMethods:
		  (aCollection flatCollect: [ :each | each allImplementations ])
		  thenSelect: [ :each | true ]
]

{ #category : #dispatched }
AbstractMethodWrapper >> compiledMethod: aCompiledMethod [

	| dict |
	compiledMethod := aCompiledMethod.

	"methodClass addSelectorSilently: selector withMethod: compiledMethod"
	dict := compiledMethod methodClass methodDict
		        at: compiledMethod selector put: self;
		        yourself
]

{ #category : #private }
AbstractMethodWrapper >> doesNotUnderstand: aMessage [

	^ self
		  ifInstalled: [ 
			  compiledMethod
				  perform: aMessage selector
				  withArguments: aMessage arguments ]
		  ifNotInstalled: [ super doesNotUnderstand: aMessage ]
]

{ #category : #accessing }
AbstractMethodWrapper >> handler: anObject [

	handler := anObject
]

{ #category : #private }
AbstractMethodWrapper >> ifInstalled: iBlock ifNotInstalled: niBlock [

	^ compiledMethod ifNil: niBlock ifNotNil: iBlock
]

{ #category : #actions }
AbstractMethodWrapper >> install [

	self
		ifInstalled: [ Warning signal: 'Already installed wrapper.' ]
		ifNotInstalled: [ 
			(methodClass lookupSelector: selector) ifNotNil: [ :aMethodOrWrapper | 
				aMethodOrWrapper installOnMethodWrapper: self ] ]
]

{ #category : #dispatched }
AbstractMethodWrapper >> installOnMethodWrapper: aWrapper [

	Warning signal: 'Attempting to wrap a wrapper'
]

{ #category : #testing }
AbstractMethodWrapper >> isCompiledMethod [

	^ false
]

{ #category : #testing }
AbstractMethodWrapper >> isMethodWrapper [

	^ true
]

{ #category : #accessing }
AbstractMethodWrapper >> methodClass: anObject [

	methodClass := anObject
]

{ #category : #printing }
AbstractMethodWrapper >> printOn: aStream [

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
AbstractMethodWrapper >> run: aSelector with: anArray in: aReceiver [

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
AbstractMethodWrapper >> selector: anObject [

	selector := anObject
]

{ #category : #actions }
AbstractMethodWrapper >> uninstall [

	self
		ifInstalled: [ 
			compiledMethod methodClass methodDict
				at: compiledMethod selector
				put: compiledMethod.

			compiledMethod := nil ]
		ifNotInstalled: [ 
		Warning signal: 'Attempted to uninstall a not installed wrapper.' ]
]
