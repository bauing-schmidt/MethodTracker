"
A MWHandlerTest is a test class for testing the behavior of MWHandler
"
Class {
	#name : #MTHandlerTest,
	#superclass : #TestCase,
	#traits : 'MTTProfilingCopying',
	#classTraits : 'MTTProfilingCopying classTrait',
	#category : #'MethodTracker-Tests'
}

{ #category : #tests }
MTHandlerTest >> exampleOpalCompiler [

	<script: 'MTHandlerTest new exampleOpalCompiler'>
	| tree metadata result handlerExecution observedData |
	tree := MTContextsTree new.

	handlerExecution := MTHandlerProfiling new
		                    tree: tree;
		                    yourself.

	result := (MTSession
		           forPackages: { #'AST-Core' asPackage }
		           selectMethod: [ :aMethod | true ])
		          do: [ :each | each handler: handlerExecution ];
		          value: [ OpalCompiler recompile ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.

	observedData := MTObservedDataset new
		                tree: tree;
		                metadata: metadata;
		                yourself.

	(MTOverviewSpPresenter on: observedData)
		umlSequenceDiagramBuilder: RSUMLSequenceBuilder new;
		openWithSpec
]

{ #category : #tests }
MTHandlerTest >> exampleOpalCompilerCount [

	<script: 'MTHandlerTest new exampleOpalCompilerCount'>
	| tree metadata result handlerExecution observedData |
	tree := MTContextsTree new.

	handlerExecution := MTHandlerCounting new.

	result := (MTSession
		           forPackages: { #'AST-Core' asPackage }
		           selectMethod: [ :aMethod | true ])
		          do: [ :each | each handler: handlerExecution ];
		          value: [ [ OpalCompiler recompile ] timeToRun ].

	result inspect.

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.

	observedData := MTObservedDataset new
		                tree: tree;
		                metadata: metadata;
		                yourself.

	(MTOverviewSpPresenter on: observedData)
		umlSequenceDiagramBuilder: RSUMLSequenceBuilder new;
		open
]

{ #category : #accessing }
MTHandlerTest >> foo [
]

{ #category : #accessing }
MTHandlerTest >> ifTrue: aBlock [

	"Fake version of `Boolean>>#ifTrue:`"

	
]

{ #category : #tests }
MTHandlerTest >> selfRaiseError [

	Error signal
]

{ #category : #tests }
MTHandlerTest >> selfSend1 [

	^ self selfSend2
]

{ #category : #tests }
MTHandlerTest >> selfSend2 [

	2 slowFibonacci addNumber: self selfSend3.

	^ (1 to: 20) asArray
]

{ #category : #tests }
MTHandlerTest >> selfSend3 [

	^ 3 slowFibonacci
]

{ #category : #tests }
MTHandlerTest >> selfSendBeforeRising: resume [

	^ [ self selfRaiseError ]
		  on: Error
		  do: [ :ex | resume ]
]

{ #category : #tests }
MTHandlerTest >> testAddWithinDoObjectCentric [

	| tree metadata result handlerExecution handlerCentric interval observedData |
	tree := MTContextsTree new.

	handlerExecution := MTHandlerProfiling new
		                    tree: tree;
		                    yourself.

	interval := 1 to: 20.

	handlerCentric := MTHandlerObjectCentric new
		                  predicate: [ :recv :args | 
			                  recv == interval or: [ recv even ] ];
		                  handler: handlerExecution;
		                  yourself.

	result := (MTSession withAllImplementations: { 
				           (Collection >> #do:).
				           (Number >> #addNumber:) })
		          do: [ :each | each handler: handlerCentric ];
		          value: [ interval do: [ :each | each addNumber: 4 ] ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.

	observedData := MTObservedDataset new
		                tree: tree;
		                metadata: metadata;
		                yourself.

	(MTOverviewSpPresenter on: observedData)
		umlSequenceDiagramBuilder: RSUMLSequenceBuilder new;
		open.

	self
		assert: tree size equals: 11;
		assert: result equals: (1 to: 20) asArray
]

{ #category : #tests }
MTHandlerTest >> testAddWithinDoª [

	^ self
		  compiledMethods: { 
				  (Collection >> #doª:).
				  (Number >> #addNumber:) }
		  wrapping: [ 
			  (1 to: 20) doª: [ :each | each addNumber: 4 ].
			  (1 to: 5) doª: [ :each | each - 4 ] ]
		  then: [ :result :observedData | 
			  | presenter tree |
			  tree := observedData tree.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: RSUMLSequenceBuilder new;
				               open;
				               yourself.

			  self
				  assert: tree size equals: 22;
				  assert: result equals: (1 to: 5) asArray ]
]

{ #category : #tests }
MTHandlerTest >> testCountAdd [

	| handler |
	handler := MTHandlerCounting new.

	(MTSession withAll: { (Number >> #addNumber:) })
		do: [ :each | each handler: handler ];
		value: [ 
			handler
				add: 3 to: 4;
				add: 3 to: 4 ].

	self assert: handler count equals: 2
]

{ #category : #tests }
MTHandlerTest >> testCountFooSingleTracker [

	| tracker handler |
	handler := MTHandlerCounting new.

	tracker := MTTracker new
		           session: MTSession new;
		           compiledMethod: self class >> #foo;
		           handler: handler;
		           yourself.

	tracker install.

	self assert:
		(tracker ifInstalled: [ true ] ifNotInstalled: [ false ]).

	self assert: (self class methodDict at: #foo) equals: tracker.

	self foo.

	tracker uninstall.

	self deny: (tracker ifInstalled: [ true ] ifNotInstalled: [ false ]).

	self assert: handler count equals: 0
]

{ #category : #tests }
MTHandlerTest >> testCountIfTrue [

	| session handler |
	handler := MTHandlerCounting new.

	session := (MTSession withAllImplementations:
			            { (Boolean >> #ifTrue:) })
		           do: [ :each | each handler: handler ];
		           yourself.

	session value: [ true ifTrue: [ 3 ] ].

	self assert: handler count equals: 0
]

{ #category : #tests }
MTHandlerTest >> testCountIfTrueDuringSlowFactorial [

	| session handler ifTrueHandler |
	handler := MTHandlerCounting new.
	ifTrueHandler := MTHandlerCounting new.

	session := (MTSession withAllImplementations:
			            { (Boolean >> #ifTrue:) })
		           do: [ :each | each handler: ifTrueHandler ];
		           add: (MTTracker new
				            compiledMethod: Integer >> #slowFactorial;
				            handler: handler;
				            yourself);
		           yourself.

	session value: [ 5 slowFactorial ].

	self
		assert: handler count equals: 6;
		assert: ifTrueHandler count equals: 0
]

{ #category : #tests }
MTHandlerTest >> testCountIfTrueSingleTracker [

	| tracker handler |
	handler := MTHandlerCounting new.

	tracker := MTTracker new
		           session: MTSession new;
		           compiledMethod: true class >> #ifTrue:;
		           handler: handler;
		           yourself.

	tracker install.

	self assert:
		(tracker ifInstalled: [ true ] ifNotInstalled: [ false ]).

	self assert: (true class methodDict at: #ifTrue:) equals: tracker.

	true ifTrue: [ 3 ].

	tracker uninstall.

	self deny: (tracker ifInstalled: [ true ] ifNotInstalled: [ false ]).

	self assert: handler count equals: 0
]

{ #category : #tests }
MTHandlerTest >> testCountSelfIfTrueSingleTracker [

	| tracker handler |
	handler := MTHandlerCounting new.

	tracker := MTTracker new
		           session: MTSession new;
		           compiledMethod: self class >> #ifTrue:;
		           handler: handler;
		           yourself.

	tracker install.

	self assert:
		(tracker ifInstalled: [ true ] ifNotInstalled: [ false ]).

	self assert: (self class methodDict at: #ifTrue:) equals: tracker.

	self ifTrue: [  ].

	tracker uninstall.

	self deny: (tracker ifInstalled: [ true ] ifNotInstalled: [ false ]).

	self assert: handler count equals: 0
]

{ #category : #tests }
MTHandlerTest >> testCountSlowFactorial [

	| handler |
	handler := MTHandlerCounting new.

	MTSession new
		add: (MTTracker new
				 compiledMethod: Integer >> #slowFactorial;
				 handler: handler;
				 yourself);
		value: [ 5 slowFactorial ].

	self assert: handler count equals: 6
]

{ #category : #tests }
MTHandlerTest >> testProfileSlowFactorial [

	^ self
		  compiledMethods: { (Integer >> #slowFactorial) }
		  wrapping: [ 5 slowFactorial ]
		  then: [ :result :observedData | 
			  | presenter tree |
			  tree := observedData tree.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: RSUMLSequenceBuilder new;
				               open;
				               yourself.

			  self
				  assert: tree size equals: 6;
				  assert: result equals: 5 factorial ]
]

{ #category : #tests }
MTHandlerTest >> testProfileSlowFibonacci [

	^ self
		  compiledMethods: { (Integer >> #slowFibonacci) }
		  wrapping: [ 10 slowFibonacci ]
		  then: [ :result :observedData | 
			  | presenter tree |
			  tree := observedData tree.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: RSUMLSequenceBuilder new;
				               open;
				               yourself.

			  self
				  assert: tree size equals: 177;
				  assert: result equals: 11 fibonacciNumbers last ]
]

{ #category : #tests }
MTHandlerTest >> testProfileSlowFibonacciMemoing [

	| handlerCounting handler tree result handlerExecution metadata observedData |
	tree := MTContextsTree new.

	handlerCounting := MTHandlerCounting new.

	handlerExecution := MTHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handler := MTHandlerMemoing new
		           handler: handlerExecution;
		           yourself.

	result := (MTSession withAllImplementations:
			           { (Number >> #addNumber:) })
		          do: [ :each | each handler: handlerCounting ];
		          add: (MTTracker new
				           compiledMethod: Integer >> #slowFibonacci;
				           handler: handler;
				           yourself);
		          value: [ 10 slowFibonacci ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.

	observedData := MTObservedDataset new
		                tree: tree;
		                metadata: metadata;
		                yourself.

	"Show here the new presenter."
	(MTOverviewSpPresenter on: observedData)
		umlSequenceDiagramBuilder: RSUMLSequenceBuilder new;
		open.

	self
		assert: tree size equals: 11;
		assert: result equals: 11 fibonacciNumbers last;
		assert: handlerCounting count equals: 9
]

{ #category : #tests }
MTHandlerTest >> testSelfSendBeforeRising [

	| tree metadata result handlerExecution observedData |
	tree := MTContextsTree new.

	handlerExecution := MTHandlerProfiling new
		                    tree: tree;
		                    yourself.

	result := (MTSession withAllImplementations: { 
				           (self class >> #selfSendBeforeRising:).
				           (self class >> #selfRaiseError) })
		          do: [ :each | each handler: handlerExecution ];
		          value: [ self selfSendBeforeRising: 0 ].

	metadata := IdentityDictionary new.

	handlerExecution metadata: metadata.

	observedData := MTObservedDataset new
		                tree: tree;
		                metadata: metadata;
		                yourself.

	(MTOverviewSpPresenter on: observedData)
		umlSequenceDiagramBuilder: RSUMLSequenceBuilder new;
		open.

	self
		assert: tree size equals: 2;
		assert: result equals: 0
]

{ #category : #tests }
MTHandlerTest >> testSelfSendsSimple [

	^ self
		  compiledMethods: { 
				  (self class >> #selfSend1).
				  (self class >> #selfSend2).
				  (self class >> #selfSend3).
				  (Integer >> #slowFibonacci).
				  (Number >> #addNumber:).
				  (Interval lookupSelector: #asArray) }
		  wrapping: [ self selfSend1 ]
		  then: [ :result :observedData | 
			  | presenter tree |
			  tree := observedData tree.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: RSUMLSequenceBuilder new;
				               open;
				               yourself.

			  self
				  assert: tree size equals: 16;
				  assert: result equals: (1 to: 20) asArray ]
]

{ #category : #tests }
MTHandlerTest >> testSelfSendsSimpleUsingPlus [

	^ self
		  compiledMethods: { 
				  (self class >> #selfSend1).
				  (self class >> #selfSend2).
				  (self class >> #selfSend3).
				  (Integer >> #slowFibonacci) }
			  , (Integer >> #+) allImplementations
		  wrapping: [ self selfSend1 ]
		  then: [ :result :observedData | 
			  | presenter tree |
			  tree := observedData tree.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: RSUMLSequenceBuilder new;
				               open;
				               yourself.

			  self assert: result equals: (1 to: 20) asArray
			  "assert: tree size equals: 33;" ]
]
