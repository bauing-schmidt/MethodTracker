"
A MWHandlerTest is a test class for testing the behavior of MWHandler
"
Class {
	#name : #MWHandlerTest,
	#superclass : #TestCase,
	#traits : 'MWTProfilingCopying',
	#classTraits : 'MWTProfilingCopying classTrait',
	#category : #'MethodWrappers-Tests'
}

{ #category : #tests }
MWHandlerTest >> exampleOpalCompiler [

	<script: 'MWHandlerTest new exampleOpalCompiler'>
	| tree metadata result handlerExecution observedData |
	tree := MWContextsTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	result := (MWSession
		           forPackages: { #'AST-Core' asPackage }
		           selectMethod: [ :aMethod | true ])
		          do: [ :each | each handler: handlerExecution ];
		          value: [ OpalCompiler recompile ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.

	observedData := MWObservedDataset new
		                tree: tree;
		                metadata: metadata;
		                yourself.

	"Show here the new presenter."
	(MWSpPresenter on: observedData) openWithSpec

	"self assert: tree size equals: 16"
]

{ #category : #accessing }
MWHandlerTest >> foo [
]

{ #category : #accessing }
MWHandlerTest >> ifTrue: aBlock [

	"Fake version of `Boolean>>#ifTrue:`"

	
]

{ #category : #tests }
MWHandlerTest >> selfRaiseError [

	Error signal
]

{ #category : #tests }
MWHandlerTest >> selfSend1 [

	^ self selfSend2
]

{ #category : #tests }
MWHandlerTest >> selfSend2 [

	2 slowFibonacci addNumber: self selfSend3.

	^ (1 to: 20) asArray
]

{ #category : #tests }
MWHandlerTest >> selfSend3 [

	^ 3 slowFibonacci
]

{ #category : #tests }
MWHandlerTest >> selfSendBeforeRising: resume [

	^ [ self selfRaiseError ]
		  on: Error
		  do: [ :ex | resume ]
]

{ #category : #tests }
MWHandlerTest >> testAddWithinDoObjectCentric [

	| tree metadata result handlerExecution handlerCentric interval observedData |
	tree := MWContextsTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	interval := 1 to: 20.

	handlerCentric := MWHandlerObjectCentric new
		                  predicate: [ :recv :args | 
			                  recv == interval or: [ recv even ] ];
		                  handler: handlerExecution;
		                  yourself.

	result := (MWSession withAllImplementations: { 
				           (Collection >> #do:).
				           (Number >> #addNumber:) })
		          do: [ :each | each handler: handlerCentric ];
		          value: [ interval do: [ :each | each addNumber: 4 ] ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.

	observedData := MWObservedDataset new
		                tree: tree;
		                metadata: metadata;
		                yourself.


	"Show here the new presenter."
	(MWSpPresenter on: observedData) openWithSpec.

	self
		assert: tree size equals: 11;
		assert: result equals: (1 to: 20) asArray
]

{ #category : #tests }
MWHandlerTest >> testAddWithinDoª [

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

			  presenter := (MWSpPresenter on: observedData)
				               useShapeSlotsDfsTree;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 22;
				  assert: result equals: (1 to: 5) asArray ]
]

{ #category : #tests }
MWHandlerTest >> testCountAdd [

	| handler |
	handler := MWHandlerCounting new.

	(MWSession withAll: { (Number >> #addNumber:) })
		do: [ :each | each handler: handler ];
		value: [ 
			handler
				add: 3 to: 4;
				add: 3 to: 4 ].

	self assert: handler count equals: 2
]

{ #category : #tests }
MWHandlerTest >> testCountFooSingleWrapper [

	| wrapper handler |
	handler := MWHandlerCounting new.

	wrapper := MWDecorator new
		           owner: MWSession new;
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
MWHandlerTest >> testCountIfTrue [

	| session handler |
	handler := MWHandlerCounting new.

	session := (MWSession withAllImplementations:
			            { (Boolean >> #ifTrue:) })
		           do: [ :each | each handler: handler ];
		           yourself.

	session value: [ true ifTrue: [ 3 ] ].

	self assert: handler count equals: 0
]

{ #category : #tests }
MWHandlerTest >> testCountIfTrueDuringSlowFactorial [

	| session handler ifTrueHandler |
	handler := MWHandlerCounting new.
	ifTrueHandler := MWHandlerCounting new.

	session := (MWSession withAllImplementations:
			            { (Boolean >> #ifTrue:) })
		           do: [ :each | each handler: ifTrueHandler ];
		           add: (MWDecorator new
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
MWHandlerTest >> testCountIfTrueSingleWrapper [

	| wrapper handler |
	handler := MWHandlerCounting new.

	wrapper := MWDecorator new
		           owner: MWSession new;
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
MWHandlerTest >> testCountSelfIfTrueSingleWrapper [

	| wrapper handler |
	handler := MWHandlerCounting new.

	wrapper := MWDecorator new
		           owner: MWSession new;
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
MWHandlerTest >> testCountSlowFactorial [

	| handler |
	handler := MWHandlerCounting new.

	MWSession new
		add: (MWDecorator new
				 compiledMethod: Integer >> #slowFactorial;
				 handler: handler;
				 yourself);
		value: [ 5 slowFactorial ].

	self assert: handler count equals: 6
]

{ #category : #tests }
MWHandlerTest >> testHeapWithAll [

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
			  | presenter tree |
			  tree := observedData tree.

			  "Show here the new presenter."
			  tree := tree select: [ :aChild :aParent | 
				          aChild == aParent
					          ifTrue: [ 
						          | method |
						          method := aParent asContextReifiedFromWrapping method.
						          method = (Heap class >> #withAll:) ]
					          ifFalse: [ true ] ].

			  presenter := (MWSpPresenter on: observedData)
				               useShapeSlotsDfsTree;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 64;
				  assert: result array
				  equals: #( 1 2 7 3 4 8 11 9 5 6 10 15 17 12 19 20 14 16 13 18 ) ]
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFactorial [

	^ self
		  compiledMethods: { (Integer >> #slowFactorial) }
		  wrapping: [ 5 slowFactorial ]
		  then: [ :result :observedData | 
			  | presenter tree |
			  tree := observedData tree.

			  presenter := (MWSpPresenter on: observedData)
				               useShapeSlotsDfsTree;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 6;
				  assert: result equals: 5 factorial ]
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFibonacci [

	^ self
		  compiledMethods: { (Integer >> #slowFibonacci) }
		  wrapping: [ 10 slowFibonacci ]
		  then: [ :result :observedData | 
			  | presenter tree |
			  tree := observedData tree.

			  presenter := (MWSpPresenter on: observedData)
				               useShapeSlotsDfsTree;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 177;
				  assert: result equals: 11 fibonacciNumbers last ]
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFibonacciMemoing [

	| handlerCounting handler tree result handlerExecution metadata observedData |
	tree := MWContextsTree new.

	handlerCounting := MWHandlerCounting new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handler := MWHandlerMemoing new
		           handler: handlerExecution;
		           yourself.

	result := (MWSession withAllImplementations:
			           { (Number >> #addNumber:) })
		          do: [ :each | each handler: handlerCounting ];
		          add: (MWDecorator new
				           compiledMethod: Integer >> #slowFibonacci;
				           handler: handler;
				           yourself);
		          value: [ 10 slowFibonacci ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.

	observedData := MWObservedDataset new
		                tree: tree;
		                metadata: metadata;
		                yourself.

	"Show here the new presenter."
	(MWSpPresenter on: observedData) openWithSpec.

	self
		assert: tree size equals: 11;
		assert: result equals: 11 fibonacciNumbers last;
		assert: handlerCounting count equals: 9
]

{ #category : #tests }
MWHandlerTest >> testSelfSendBeforeRising [

	| tree metadata result handlerExecution observedData |
	tree := MWContextsTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	result := (MWSession withAllImplementations: { 
				           (self class >> #selfSendBeforeRising:).
				           (self class >> #selfRaiseError) })
		          do: [ :each | each handler: handlerExecution ];
		          value: [ self selfSendBeforeRising: 0 ].

	metadata := IdentityDictionary new.

	handlerExecution metadata: metadata.

	observedData := MWObservedDataset new
		                tree: tree;
		                metadata: metadata;
		                yourself.

	(MWSpPresenter on: observedData) openWithSpec.

	self
		assert: tree size equals: 2;
		assert: result equals: 0
]

{ #category : #tests }
MWHandlerTest >> testSelfSendsSimple [

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

			  presenter := (MWSpPresenter on: observedData)
				               useShapeSlotsDfsTree;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 16;
				  assert: result equals: (1 to: 20) asArray ]
]

{ #category : #tests }
MWHandlerTest >> testSelfSendsSimpleUsingPlus [

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

			  presenter := (MWSpPresenter on: observedData)
				               useShapeSlotsDfsTree;
				               openWithSpec;
				               yourself.

			  self assert: result equals: (1 to: 20) asArray
			  "assert: tree size equals: 33;" ]
]

{ #category : #tests }
MWHandlerTest >> testSelfSendsSimpleWithOutlinerShapes [

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

			  presenter := (MWSpPresenter on: observedData)
				               useShapeSlotsDfsTree;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 16;
				  assert: result equals: (1 to: 20) asArray ]
]

{ #category : #tests }
MWHandlerTest >> testSequenceableCollectionMergeSortCopying [

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
			  | presenter tree |
			  tree := observedData tree.

			  presenter := (MWSpPresenter on: observedData)
				               useShapeSlotsDfsTree;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 81;
				  assert: result equals: (1 to: 20) asArray ]
]

{ #category : #tests }
MWHandlerTest >> testSequenceableCollectionMergeSortCopyingDetailed [

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
			  | presenter tree |
			  tree := observedData tree.

			  presenter := (MWSpPresenter on: observedData)
				               useShapeSlotsDfsTree;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 103;
				  assert: result equals: (1 to: 20) asArray ]
]

{ #category : #tests }
MWHandlerTest >> testSequenceableCollectionMergeSortPlugging [

	| tree metadata result handlerExecution handlerBlockPlugging observedData |
	tree := MWContextsTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handlerBlockPlugging := MWHandlerSuspendPlugging new
		                        handler: handlerExecution;
		                        pre: [ (1 to: 20) shuffled sort ];
		                        post: [  ];
		                        yourself.

	result := (MWSession withAllImplementations: { 
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

	observedData := MWObservedDataset new
		                tree: tree;
		                metadata: metadata;
		                yourself.

	"Show here the new presenter."
	(MWSpPresenter on: observedData) openWithSpec.

	self
		assert: tree size equals: 81;
		assert: result equals: (1 to: 20) asArray
]

{ #category : #tests }
MWHandlerTest >> testSequenceableCollectionMergeSortWithoutCopying [

	| tree result handlerExecution metadata observedData |
	tree := MWContextsTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	result := (MWSession withAllImplementations: { 
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

	observedData := MWObservedDataset new
		                tree: tree;
		                metadata: metadata;
		                yourself.

	"Show here the new presenter."
	(MWSpPresenter on: observedData) openWithSpec.

	self
		assert: tree size equals: 81;
		assert: result equals: (1 to: 20) asArray
]
