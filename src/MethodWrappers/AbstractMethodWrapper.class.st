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

{ #category : #API }
AbstractMethodWrapper class >> forPackages: aCollection selectMethod: methodBlock [
	
	| methods |
	methods := aCollection asOrderedCollection flatCollect: [ :each | each methods ].
	
	^ self forMethods: methods selectMethod: methodBlock
]

{ #category : #'instance creation' }
AbstractMethodWrapper class >> on: aMethodReference [

	^ self new initializeOn: aMethodReference
]

{ #category : #initialization }
AbstractMethodWrapper class >> reset [

	<script>
	self allInstances do: #uninstall.
	SpNullApplication reset.
	Smalltalk garbageCollect
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

{ #category : #initialization }
AbstractMethodWrapper >> initializeOn: aMethodReference [

	reference := aMethodReference.
	method := reference compiledMethod.

	installed := false.
	self disable
]

{ #category : #actions }
AbstractMethodWrapper >> install [

	installed
		ifTrue: [ Error signal ]
		ifFalse: [ reference installWrapper: self ]
]

{ #category : #actions }
AbstractMethodWrapper >> installCompiledMethod: aCompiledMethod [

	reference == aCompiledMethod
		ifTrue: [ 
			reference methodClass methodDict at: reference selector put: self.
			installed := true ]
		ifFalse: [ Error signal ]
]

{ #category : #actions }
AbstractMethodWrapper >> installWrapper: aWrapper [

	Warning signal: 'Attempting to wrap a wrapper'
]

{ #category : #accessing }
AbstractMethodWrapper >> method [
	^ method
]

{ #category : #evaluation }
AbstractMethodWrapper >> noticeExecutionWith: anArray in: aReceiver [

	self subclassResponsibility
]

{ #category : #accessing }
AbstractMethodWrapper >> reference [
	^ reference
]

{ #category : #evaluation }
AbstractMethodWrapper >> run: aSelector with: anArray in: aReceiver [

	aSelector == method selector ifFalse: [ Error signal ].

	enabled ifTrue: [ self noticeExecutionWith: anArray in: aReceiver ].

	^ aReceiver withArgs: anArray executeMethod: method
]

{ #category : #actions }
AbstractMethodWrapper >> uninstall [

	installed
		ifTrue: [ 
			reference methodClass methodDict at: reference selector put: method.
			installed := false ]
		ifFalse: [ Error signal ]
]
