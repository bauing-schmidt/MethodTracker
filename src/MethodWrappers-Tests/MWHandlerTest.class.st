"
A MWHandlerTest is a test class for testing the behavior of MWHandler
"
Class {
	#name : #MWHandlerTest,
	#superclass : #TestCase,
	#category : #'MethodWrappers-Tests'
}

{ #category : #accessing }
MWHandlerTest >> foo [
]

{ #category : #accessing }
MWHandlerTest >> ifTrue: aBlock [

	"Fake version of `Boolean>>#ifTrue:`"

	
]

{ #category : #tests }
MWHandlerTest >> selfSend1 [

	^ self selfSend2
]

{ #category : #tests }
MWHandlerTest >> selfSend2 [

	2 slowFibonacci add: self selfSend3.

	^ (1 to: 20) asArray
]

{ #category : #tests }
MWHandlerTest >> selfSend3 [

	^ 3 slowFibonacci
]

{ #category : #tests }
MWHandlerTest >> testAddWithinDoObjectCentric [

	| tree metadata result handlerExecution handlerCentric interval |
	tree := CTOrderPreservingTree new.

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
				           (Number >> #add:) })
		          do: [ :each | each handler: handlerCentric ];
		          value: [ interval do: [ :each | each add: 4 ] ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 11;
		assert: result equals: (1 to: 20) asArray
]

{ #category : #tests }
MWHandlerTest >> testAddWithinDoª [

	| tree metadata result handlerExecution |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	result := (MWSession withAllImplementations: { 
				           (Collection >> #doª:).
				           (Number >> #add:) })
		          do: [ :each | each handler: handlerExecution ];
		          value: [ 
			          (1 to: 20) doª: [ :each | each add: 4 ].
			          (1 to: 5) doª: [ :each | each - 4 ] ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 22;
		assert: result equals: (1 to: 5) asArray
]

{ #category : #tests }
MWHandlerTest >> testCountAdd [

	| handler |
	handler := MWHandlerCounting new.

	(MWSession withAllImplementations: { (Number >> #add:) })
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

	| tree result handlerExecution handlerCopying metadata |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handlerCopying := MWHandlerReceiverArgumentsCopying new
		                  handler: handlerExecution;
		                  yourself.

	result := (MWSession withAllImplementations: { 
				           (Heap class >> #withAll:).
				           (Heap >> #reSort).
				           (Heap >> #downHeap:).
				           (Heap >> #sorts:before:).
				           (Integer >> #bitShift:) })
		          add: (MWDecorator new
				           compiledMethod: (Array lookupSelector: #at:put:);
				           yourself);
		          do: [ :each | each handler: handlerCopying ];
		          value: [ 
			          Heap withAll: ((1 to: 20) asArray
					           shuffleBy: (Random seed: 17);
					           yourself) ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerCopying metadata: metadata.

	"Show here the new presenter."
	tree := tree select: [ :aChild :aParent | 
		        aChild == aParent
			        ifTrue: [ 
				        | method |
				        method := aParent asContextReifiedFromWrapping method.
				        method = (Heap class >> #withAll:) ]
			        ifFalse: [ true ] ].

	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 74;
		assert: result array
		equals: #( 1 2 7 3 4 8 11 9 5 6 10 15 17 12 19 20 14 16 13 18 )
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFactorial [

	| result tree metadata handlerExecution |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	result := MWSession new
		          add: (MWDecorator new
				           compiledMethod: Integer >> #slowFactorial;
				           handler: handlerExecution;
				           yourself);
		          value: [ 5 slowFactorial ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 6;
		assert: result equals: 5 factorial
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFibonacci [

	| handlerExecution tree metadata result |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	result := MWSession new
		          add: (MWDecorator new
				           compiledMethod: Integer >> #slowFibonacci;
				           handler: handlerExecution;
				           yourself);
		          value: [ 10 slowFibonacci ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 177;
		assert: result equals: 11 fibonacciNumbers last
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFibonacciMemoing [

	| handlerCounting handler tree result handlerExecution metadata |
	tree := CTOrderPreservingTree new.

	handlerCounting := MWHandlerCounting new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handler := MWHandlerMemoing new
		           handler: handlerExecution;
		           yourself.

	result := (MWSession withAllImplementations: { (Number >> #add:) })
		          do: [ :each | each handler: handlerCounting ];
		          add: (MWDecorator new
				           compiledMethod: Integer >> #slowFibonacci;
				           handler: handler;
				           yourself);
		          value: [ 10 slowFibonacci ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 19;
		assert: result equals: 11 fibonacciNumbers last;
		assert: handlerCounting count equals: 9
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFibonacciTailWithAdd [

	| wrapper handlerExecution tree metadata result wrapperAdd |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	wrapper := MWDecorator new
		           compiledMethod: Integer >> #slowFibonacci:tail:;
		           handler: handlerExecution;
		           yourself.

	wrapperAdd := MWDecorator new
		              compiledMethod: Number >> #add:;
		              handler: handlerExecution;
		              yourself.

	result := MWSession new
		          add: wrapper;
		          add: wrapperAdd;
		          value: [ 10 slowFibonacci: 0 tail: 1 ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 21;
		assert: result equals: 11 fibonacciNumbers last
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFibonacciWithAdd [

	| wrapper handlerExecution tree metadata result wrapperAdd |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	wrapper := MWDecorator new
		           compiledMethod: Integer >> #slowFibonacci;
		           handler: handlerExecution;
		           yourself.

	wrapperAdd := MWDecorator new
		              compiledMethod: Number >> #add:;
		              handler: handlerExecution;
		              yourself.

	result := MWSession new
		          add: wrapper;
		          add: wrapperAdd;
		          value: [ 10 slowFibonacci ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 265;
		assert: result equals: 11 fibonacciNumbers last " 55"
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFibonacciWithAddOnly [

	| handlerExecution tree metadata result wrapperAdd |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	wrapperAdd := MWDecorator new
		              compiledMethod: Number >> #add:;
		              handler: handlerExecution;
		              yourself.

	result := MWSession new
		          add: wrapperAdd;
		          value: [ 10 slowFibonacci ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 88;
		assert: result equals: 11 fibonacciNumbers last " 55"
]

{ #category : #tests }
MWHandlerTest >> testSelfSendsSimple [

	|  tree metadata result handlerExecution |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	result := (MWSession withAllImplementations: { 
				           (self class >> #selfSend1).
				           (self class >> #selfSend2).
				           (self class >> #selfSend3).
				           (Integer >> #slowFibonacci).
				           (Number >> #add:).
				           (Interval lookupSelector: #asArray) })
		          do: [ :each | each handler: handlerExecution ];
		          value: [ self selfSend1 ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata)
		useShapeSlotsDfsTree;
		openWithSpec.

	self
		assert: tree size equals: 16;
		assert: result equals: (1 to: 20) asArray
]

{ #category : #tests }
MWHandlerTest >> testSelfSendsSimpleUsingPlus [

	| tree metadata result handlerExecution |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	result := (MWSession withAllImplementations: { 
				           (self class >> #selfSend1).
				           (self class >> #selfSend2).
				           (self class >> #selfSend3).
				           (Integer >> #slowFibonacci).
				           (Integer >> #+) })
		          do: [ :each | each handler: handlerExecution ];
		          value: [ self selfSend1 ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 33;
		assert: result equals: (1 to: 20) asArray
]

{ #category : #tests }
MWHandlerTest >> testSequenceableCollectionMergeSort [

	| tree metadata result handlerExecution |
	tree := CTOrderPreservingTree new.

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

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 81;
		assert: result equals: (1 to: 20) asArray
]

{ #category : #tests }
MWHandlerTest >> testSequenceableCollectionMergeSortCopying [

	| tree result handlerExecution handlerCopying metadata |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handlerCopying := MWHandlerReceiverArgumentsCopying new
		                  handler: handlerExecution;
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
		          do: [ :each | each handler: handlerCopying ];
		          value: [ (1 to: 20) shuffled sort ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerCopying metadata: metadata.

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata)
		useShapeSlotsDfsTree;
		openWithSpec.

	self
		assert: tree size equals: 81;
		assert: result equals: (1 to: 20) asArray
]

{ #category : #tests }
MWHandlerTest >> testSequenceableCollectionMergeSortCopyingDetailed [

	| tree metadata result handlerExecution handlerCopying |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handlerCopying := MWHandlerReceiverArgumentsCopying new
		                  handler: handlerExecution;
		                  yourself.

	result := (MWSession withAllImplementations: { 
				           (SequenceableCollection >> #sort).
				           (SequenceableCollection >> #mergeSortFrom:to:by:).
				           (SequenceableCollection
				            >> #mergeFirst:middle:last:into:by:).
				           (SequenceableCollection
				            >> #mergeSortFrom:to:src:dst:by:).
				           (SequenceableCollection
				            >> #replaceFrom:to:with:startingAt:).
				           (SequenceableCollection >> #shuffled).
				           (SequenceableCollection >> #shuffle).
				           (SequenceableCollection >> #shuffleBy:).
				           (SequenceableCollection >> #swap:with:) })
		          do: [ :each | each handler: handlerCopying ];
		          value: [ (1 to: 20) shuffled sort ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerCopying metadata: metadata.

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 103;
		assert: result equals: (1 to: 20) asArray
]

{ #category : #tests }
MWHandlerTest >> testSequenceableCollectionMergeSortPlugging [

	| tree metadata result handlerExecution handlerBlockPlugging |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handlerBlockPlugging := MWHandlerSuspendPlugging new
		                        handler: handlerExecution;
		                        blockClosure: [ :session | 
			                        (1 to: 20) shuffled sort ];
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

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 81;
		assert: result equals: (1 to: 20) asArray
]

{ #category : #tests }
MWHandlerTest >> testTimingSlowFibonacciMemoing [

	| handlerMemoing tree metadata result handlerExecution |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handlerMemoing := MWHandlerMemoing new
		                  handler: handlerExecution;
		                  yourself.

	result := MWSession new
		          add: (MWDecorator new
				           compiledMethod: Integer >> #slowFibonacci;
				           handler: handlerMemoing;
				           yourself);
		          value: [ 10 slowFibonacci ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerMemoing metadata: metadata.

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 19;
		assert: result equals: 11 fibonacciNumbers last
]
