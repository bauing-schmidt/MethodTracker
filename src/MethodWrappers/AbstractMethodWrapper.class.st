"
I am an abstract class that install a wrapper around a compiled method, and uninstall it when finished my scope.
"
Class {
	#name : #AbstractMethodWrapper,
	#superclass : #ProtoObject,
	#instVars : [
		'reference',
		'method',
		'enabled',
		'installed'
	],
	#category : #MethodWrappers
}

{ #category : #API }
AbstractMethodWrapper class >> forBaselineClass: aBaselineClass selectMethod: methodBlock [
	
	| methods |
	methods := (aBaselineClass allPackageNames collect: [ :each | 
		            each asPackage ]) flatCollect: [ :each | each methods ].
	
	^ self forMethods: methods selectMethod: methodBlock
]

{ #category : #API }
AbstractMethodWrapper class >> forMethods: aCollection selectMethod: methodBlock [

	| methods excludingClasses |
	excludingClasses := AbstractMethodWrapper withAllSubclasses asSet.

	methods := aCollection select: [ :aMethod | 
			           (excludingClasses includes: aMethod methodClass) not 
				           and: [ methodBlock value: aMethod ] ] .

	^ methods collect: [ :each | self on: each ]
]

{ #category : #'instance creation' }
AbstractMethodWrapper class >> on: aMethodReference [

	^ self new initializeOn: aMethodReference
]

{ #category : #protocol }
AbstractMethodWrapper >> disable [

	enabled := false
]

{ #category : #private }
AbstractMethodWrapper >> doesNotUnderstand: aMessage [
	^ method perform: aMessage selector withArguments: aMessage arguments
]

{ #category : #protocol }
AbstractMethodWrapper >> enable [

	enabled := true
]

{ #category : #actions }
AbstractMethodWrapper >> hasBeenInstalled [

	installed := true
]

{ #category : #initialization }
AbstractMethodWrapper >> initializeOn: aMethodReference [

	reference := aMethodReference.
	method := reference compiledMethod
]

{ #category : #actions }
AbstractMethodWrapper >> install [

	installed := false.
	reference installWrapper: self
]

{ #category : #actions }
AbstractMethodWrapper >> installWrapper: aWrapper [

	Warning signal: 'Attempting to wrap a wrapper'
]

{ #category : #accessing }
AbstractMethodWrapper >> method [
	^ method
]

{ #category : #accessing }
AbstractMethodWrapper >> reference [
	^ reference
]

{ #category : #evaluation }
AbstractMethodWrapper >> run: aSelector with: anArray in: aReceiver [

	^ aReceiver withArgs: anArray executeMethod: method
]

{ #category : #actions }
AbstractMethodWrapper >> uninstall [

	reference methodClass methodDict at: reference selector put: method
]
