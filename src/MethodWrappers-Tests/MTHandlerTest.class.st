"
A MWHandlerTest is a test class for testing the behavior of MWHandler
"
Class {
	#name : #MTHandlerTest,
	#superclass : #TestCase,
	#traits : 'MTTProfilingCopying + MTTUmlSequenceDiagramBuilderWithOutliners',
	#classTraits : 'MTTProfilingCopying classTrait + MTTUmlSequenceDiagramBuilderWithOutliners classTrait',
	#category : #'MethodWrappers-Tests'
}

{ #category : #tests }
MTHandlerTest >> exampleOpalCompiler [

	<script: 'MWHandlerTest new exampleOpalCompiler'>
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
		openWithSpec.

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
			  | presenter tree builder |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
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
MTHandlerTest >> testCountFooSingleWrapper [

	| wrapper handler |
	handler := MTHandlerCounting new.

	wrapper := MTDecorator new
		           owner: MTSession new;
		           compiledMethod: self class >> #foo;
		           handler: handler;
		           yourself.

	wrapper install.

	self assert:
		(wrapper ifInstalled: [ true ] ifNotInstalled: [ false ]).

	self assert: (self class methodDict at: #foo) equals: wrapper.

	self foo.

	wrapper uninstall.

	self deny: (wrapper ifInstalled: [ true ] ifNotInstalled: [ false ]).

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
		           add: (MTDecorator new
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
MTHandlerTest >> testCountIfTrueSingleWrapper [

	| wrapper handler |
	handler := MTHandlerCounting new.

	wrapper := MTDecorator new
		           owner: MTSession new;
		           compiledMethod: true class >> #ifTrue:;
		           handler: handler;
		           yourself.

	wrapper install.

	self assert:
		(wrapper ifInstalled: [ true ] ifNotInstalled: [ false ]).

	self assert: (true class methodDict at: #ifTrue:) equals: wrapper.

	true ifTrue: [ 3 ].

	wrapper uninstall.

	self deny: (wrapper ifInstalled: [ true ] ifNotInstalled: [ false ]).

	self assert: handler count equals: 0
]

{ #category : #tests }
MTHandlerTest >> testCountSelfIfTrueSingleWrapper [

	| wrapper handler |
	handler := MTHandlerCounting new.

	wrapper := MTDecorator new
		           owner: MTSession new;
		           compiledMethod: self class >> #ifTrue:;
		           handler: handler;
		           yourself.

	wrapper install.

	self assert:
		(wrapper ifInstalled: [ true ] ifNotInstalled: [ false ]).

	self assert: (self class methodDict at: #ifTrue:) equals: wrapper.

	self ifTrue: [  ].

	wrapper uninstall.

	self deny: (wrapper ifInstalled: [ true ] ifNotInstalled: [ false ]).

	self assert: handler count equals: 0
]

{ #category : #tests }
MTHandlerTest >> testCountSlowFactorial [

	| handler |
	handler := MTHandlerCounting new.

	MTSession new
		add: (MTDecorator new
				 compiledMethod: Integer >> #slowFactorial;
				 handler: handler;
				 yourself);
		value: [ 5 slowFactorial ].

	self assert: handler count equals: 6
]

{ #category : #tests }
MTHandlerTest >> testHeapWithAll [

	^ self
		  compiledMethods: { 
				  (Heap class >> #withAll:).
				  (Heap >> #reSort).
				  (Heap >> #downHeap:).
				  (Heap >> #sorts:before:).
				  (Integer >> #bitShift:).
				  (Array lookupSelector: #at:put:) }
		  wrapping: [ 
			  Heap withAll: ((1 to: 20) asArray
					   shuffleBy: (Random seed: 17);
					   yourself) ]
		  then: [ :result :observedData | 
			  | presenter tree builder |
			  tree := observedData tree select: [ :aChild :aParent | 
				          aChild == aParent
					          ifTrue: [ 
						          | method |
						          method := aParent asContextReifiedFromWrapping method.
						          method = (Heap class >> #withAll:) ]
					          ifFalse: [ true ] ].

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 64;
				  assert: result array
				  equals: #( 1 2 7 3 4 8 11 9 5 6 10 15 17 12 19 20 14 16 13 18 ) ]
]

{ #category : #tests }
MTHandlerTest >> testProfileSlowFactorial [

	^ self
		  compiledMethods: { (Integer >> #slowFactorial) }
		  wrapping: [ 5 slowFactorial ]
		  then: [ :result :observedData | 
			  | presenter tree builder |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
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
			  | presenter tree builder |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
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
		          add: (MTDecorator new
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
		openWithSpec.

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
		openWithSpec.

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
			  | presenter tree builder |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
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
			  | presenter tree builder |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
				               yourself.

			  self assert: result equals: (1 to: 20) asArray
			  "assert: tree size equals: 33;" ]
]

{ #category : #tests }
MTHandlerTest >> testSelfSendsSimpleWithOutlinerShapes [

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
			  | presenter tree builder |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 16;
				  assert: result equals: (1 to: 20) asArray ]
]

{ #category : #tests }
MTHandlerTest >> testSequenceableCollectionMergeSortCopying [

	^ self
		  compiledMethods: { 
				  (SequenceableCollection >> #sort).
				  (SequenceableCollection >> #mergeSortFrom:to:by:).
				  (SequenceableCollection >> #mergeFirst:middle:last:into:by:).
				  (SequenceableCollection >> #mergeSortFrom:to:src:dst:by:) }
			  , (SequenceableCollection >> #replaceFrom:to:with:startingAt:)
					  allImplementations
		  wrapping: [ (1 to: 20) shuffled sort ]
		  then: [ :result :observedData | 
			  | presenter tree builder |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 81;
				  assert: result equals: (1 to: 20) asArray ]
]

{ #category : #tests }
MTHandlerTest >> testSequenceableCollectionMergeSortCopyingDetailed [

	^ self
		  compiledMethods: { 
				  (SequenceableCollection >> #sort).
				  (SequenceableCollection >> #mergeSortFrom:to:by:).
				  (SequenceableCollection >> #mergeFirst:middle:last:into:by:).
				  (SequenceableCollection >> #mergeSortFrom:to:src:dst:by:).
				  (SequenceableCollection >> #shuffle).
				  (SequenceableCollection >> #shuffleBy:).
				  (SequenceableCollection >> #swap:with:) }
			  , (SequenceableCollection >> #replaceFrom:to:with:startingAt:)
					  allImplementations
			  , (SequenceableCollection >> #shuffled) allImplementations
		  wrapping: [ (1 to: 20) shuffled sort ]
		  then: [ :result :observedData | 
			  | presenter tree builder |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 103;
				  assert: result equals: (1 to: 20) asArray ]
]

{ #category : #tests }
MTHandlerTest >> testSequenceableCollectionMergeSortPlugging [

	| tree metadata result handlerExecution handlerBlockPlugging observedData |
	tree := MTContextsTree new.

	handlerExecution := MTHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handlerBlockPlugging := MTHandlerSuspendPlugging new
		                        handler: handlerExecution;
		                        pre: [ (1 to: 20) shuffled sort ];
		                        post: [  ];
		                        yourself.

	result := (MTSession withAllImplementations: { 
				           (SequenceableCollection >> #sort).
				           (SequenceableCollection >> #mergeSortFrom:to:by:).
				           (SequenceableCollection
				            >> #mergeFirst:middle:last:into:by:).
				           (SequenceableCollection
				            >> #mergeSortFrom:to:src:dst:by:).
				           (SequenceableCollection
				            >> #replaceFrom:to:with:startingAt:) })
		          do: [ :each | each handler: handlerBlockPlugging ];
		          value: [ (1 to: 20) shuffled sort ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerBlockPlugging metadata: metadata.

	observedData := MTObservedDataset new
		                tree: tree;
		                metadata: metadata;
		                yourself.

	"Show here the new presenter."
	(MTOverviewSpPresenter on: observedData)
		umlSequenceDiagramBuilder: RSUMLSequenceBuilder new;
		openWithSpec.

	self
		assert: tree size equals: 81;
		assert: result equals: (1 to: 20) asArray
]

{ #category : #tests }
MTHandlerTest >> testSequenceableCollectionMergeSortWithoutCopying [

	| tree result handlerExecution metadata observedData |
	tree := MTContextsTree new.

	handlerExecution := MTHandlerProfiling new
		                    tree: tree;
		                    yourself.

	result := (MTSession withAllImplementations: { 
				           (SequenceableCollection >> #sort).
				           (SequenceableCollection >> #mergeSortFrom:to:by:).
				           (SequenceableCollection
				            >> #mergeFirst:middle:last:into:by:).
				           (SequenceableCollection
				            >> #mergeSortFrom:to:src:dst:by:).
				           (SequenceableCollection
				            >> #replaceFrom:to:with:startingAt:) })
		          do: [ :each | each handler: handlerExecution ];
		          value: [ (1 to: 20) shuffled sort ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.

	observedData := MTObservedDataset new
		                tree: tree;
		                metadata: metadata;
		                yourself.

	"Show here the new presenter."
	(MTOverviewSpPresenter on: observedData)
		umlSequenceDiagramBuilder: RSUMLSequenceBuilder new;
		openWithSpec.

	self
		assert: tree size equals: 81;
		assert: result equals: (1 to: 20) asArray
]
