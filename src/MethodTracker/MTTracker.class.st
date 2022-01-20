"
I am an abstract class that install a wrapper around a compiled method, and uninstall it when finished my scope.
"
Class {
	#name : #MTTracker,
	#superclass : #Object,
	#instVars : [
		'compiledMethod',
		'handler',
		'session'
	],
	#category : #MethodTracker
}

{ #category : #initialization }
MTTracker class >> doInspectAllInstances [

	<script>
	self inspectAllInstances
]

{ #category : #initialization }
MTTracker class >> reset [

	<script>
	self allSubclassesDo: [ :each | 
		each allInstances do: [ :w | 
			[ w uninstall ] onDNU: #uninstall do: [  ] ] ].

	SpNullApplication reset.

	Smalltalk garbageCollect
]

{ #category : #initialization }
MTTracker >> compiledMethod [

	^ compiledMethod
]

{ #category : #initialization }
MTTracker >> compiledMethod: aCompiledMethod [

	compiledMethod := aCompiledMethod
]

{ #category : #private }
MTTracker >> doesNotUnderstand: aMessage [

	^ compiledMethod
		  perform: aMessage selector
		  withArguments: aMessage arguments
]

{ #category : #accessing }
MTTracker >> handler: anObject [

	handler := anObject
]

{ #category : #private }
MTTracker >> ifInstalled: iBlock ifNotInstalled: niBlock [

	^ compiledMethod methodClass methodDict
		  at: compiledMethod selector
		  ifPresent: [ :aMethod | 
			  aMethod == self
				  ifTrue: iBlock
				  ifFalse: niBlock ]
		  ifAbsent: [ Error signal ]
]

{ #category : #actions }
MTTracker >> install [

	self
		ifInstalled: [ Warning signal: 'Already installed wrapper.' ]
		ifNotInstalled: [ self put: self ]
]

{ #category : #accessing }
MTTracker >> owner: anObject [

	session := anObject
]

{ #category : #printing }
MTTracker >> printOn: aStream [

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
MTTracker >> put: aMethod [

	compiledMethod methodClass methodDict
		at: compiledMethod selector put: aMethod;
		rehash
]

{ #category : #evaluation }
MTTracker >> run: aSelector with: anArray in: aReceiver [

	self assert: aSelector = compiledMethod selector.

	^ session
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  context: thisContext
		  tracker: self
]

{ #category : #'as yet unclassified' }
MTTracker >> run: aSelector with: anArray in: aReceiver context: aContext notSuspended: aBoolean [

	^ handler
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  context: aContext
		  tracker: self
]

{ #category : #'as yet unclassified' }
MTTracker >> run: aSelector with: anArray in: aReceiver context: aContext suspended: aBoolean [

	^ self valueWithReceiver: aReceiver arguments: anArray
]

{ #category : #actions }
MTTracker >> uninstall [

	self
		ifInstalled: [ self put: compiledMethod ]
		ifNotInstalled: [ 
		Warning signal: 'Attempted to uninstall a not installed wrapper.' ]
]

{ #category : #evaluation }
MTTracker >> valueWithReceiver: aReceiver arguments: anArray [

	^ aReceiver withArgs: anArray executeMethod: compiledMethod
]

{ #category : #evaluation }
MTTracker >> withSuspendWrapping: aBlock context: aContext [

	^ [ session pushContext: aContext ]
		  value: [ aBlock cull: session ]
		  then: [ session popContext: aContext ]
]
