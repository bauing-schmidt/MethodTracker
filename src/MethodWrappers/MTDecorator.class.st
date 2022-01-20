"
I am an abstract class that install a wrapper around a compiled method, and uninstall it when finished my scope.
"
Class {
	#name : #MTDecorator,
	#superclass : #Object,
	#instVars : [
		'compiledMethod',
		'handler',
		'session'
	],
	#category : #MethodWrappers
}

{ #category : #initialization }
MTDecorator class >> doInspectAllInstances [

	<script>
	self inspectAllInstances
]

{ #category : #initialization }
MTDecorator class >> reset [

	<script>
	self allSubclassesDo: [ :each | 
		each allInstances do: [ :w | 
			[ w uninstall ] onDNU: #uninstall do: [  ] ] ].

	SpNullApplication reset.

	Smalltalk garbageCollect
]

{ #category : #initialization }
MTDecorator >> compiledMethod [

	^ compiledMethod
]

{ #category : #initialization }
MTDecorator >> compiledMethod: aCompiledMethod [

	compiledMethod := aCompiledMethod
]

{ #category : #private }
MTDecorator >> doesNotUnderstand: aMessage [

	^ compiledMethod
		  perform: aMessage selector
		  withArguments: aMessage arguments
]

{ #category : #accessing }
MTDecorator >> handler: anObject [

	handler := anObject
]

{ #category : #private }
MTDecorator >> ifInstalled: iBlock ifNotInstalled: niBlock [

	^ compiledMethod methodClass methodDict
		  at: compiledMethod selector
		  ifPresent: [ :aMethod | 
			  aMethod == self
				  ifTrue: iBlock
				  ifFalse: niBlock ]
		  ifAbsent: [ Error signal ]
]

{ #category : #actions }
MTDecorator >> install [

	self
		ifInstalled: [ Warning signal: 'Already installed wrapper.' ]
		ifNotInstalled: [ self put: self ]
]

{ #category : #accessing }
MTDecorator >> owner: anObject [

	session := anObject
]

{ #category : #printing }
MTDecorator >> printOn: aStream [

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
MTDecorator >> put: aMethod [

	compiledMethod methodClass methodDict
		at: compiledMethod selector put: aMethod;
		rehash
]

{ #category : #evaluation }
MTDecorator >> run: aSelector with: anArray in: aReceiver [

	self assert: aSelector = compiledMethod selector.

	^ session
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  context: thisContext
		  wrapper: self
]

{ #category : #'as yet unclassified' }
MTDecorator >> run: aSelector with: anArray in: aReceiver context: aContext notSuspended: aBoolean [

	^ handler
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  context: aContext
		  wrapper: self
]

{ #category : #'as yet unclassified' }
MTDecorator >> run: aSelector with: anArray in: aReceiver context: aContext suspended: aBoolean [

	^ self valueWithReceiver: aReceiver arguments: anArray
]

{ #category : #actions }
MTDecorator >> uninstall [

	self
		ifInstalled: [ self put: compiledMethod ]
		ifNotInstalled: [ 
		Warning signal: 'Attempted to uninstall a not installed wrapper.' ]
]

{ #category : #evaluation }
MTDecorator >> valueWithReceiver: aReceiver arguments: anArray [

	^ aReceiver withArgs: anArray executeMethod: compiledMethod
]

{ #category : #evaluation }
MTDecorator >> withSuspendWrapping: aBlock context: aContext [

	^ [ session pushContext: aContext ]
		  value: [ aBlock cull: session ]
		  then: [ session popContext: aContext ]
]
