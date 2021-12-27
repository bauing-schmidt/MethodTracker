"
I am an abstract class that install a wrapper around a compiled method, and uninstall it when finished my scope.
"
Class {
	#name : #MWDecorator,
	#superclass : #Object,
	#instVars : [
		'compiledMethod',
		'handler',
		'session'
	],
	#category : #MethodWrappers
}

{ #category : #initialization }
MWDecorator class >> doInspectAllInstances [

	<script>
	self inspectAllInstances
]

{ #category : #initialization }
MWDecorator class >> reset [

	<script>
	self allSubclassesDo: [ :each | 
		each allInstances do: [ :w | 
			[ w uninstall ] onDNU: #uninstall do: [  ] ] ].

	SpNullApplication reset.

	Smalltalk garbageCollect
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

{ #category : #accessing }
MWDecorator >> owner: anObject [

	session := anObject
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

	self assert: aSelector = compiledMethod selector.

	^ session
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  context: thisContext
		  wrapper: self
]

{ #category : #'as yet unclassified' }
MWDecorator >> run: aSelector with: anArray in: aReceiver context: aContext notSuspended: aBoolean [

	^ handler
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  context: aContext
		  wrapper: self
]

{ #category : #'as yet unclassified' }
MWDecorator >> run: aSelector with: anArray in: aReceiver context: aContext suspended: aBoolean [

	^ self valueWithReceiver: aReceiver arguments: anArray
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

{ #category : #evaluation }
MWDecorator >> valueWithReceiver: aReceiver arguments: anArray timed: model [

	| result start |
	self
		withSuspendWrapping: [ start := Time microsecondClockValue ]
		context: thisContext.

	result := self valueWithReceiver: aReceiver arguments: anArray.

	self
		withSuspendWrapping: [ 
			| duration now by |
			now := Time microsecondClockValue.
			by := 1.
			now = start ifTrue: [ now := now + by ].
			duration := start to: now by: by.

			model
				result: result;
				duration: duration ]
		context: thisContext.

	^ result
]

{ #category : #evaluation }
MWDecorator >> withSuspendWrapping: aBlock context: aContext [

	^ [ session pushContext: aContext ]
		  value: [ aBlock cull: session ]
		  then: [ session popContext: aContext ]
]
