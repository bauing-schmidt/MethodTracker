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
MWHandlerTest >> testAddWithinDo [

	| handlerTiming handlerMemoing tree presenter result handlerProfiler |
	tree := CTOrderPreservingTree new.

	handlerProfiler := MWHandlerProfiling new
		                   tree: tree;
		                   yourself.

	handlerMemoing := MWHandlerMemoing new
		                  handler: handlerProfiler;
		                  yourself.

	handlerTiming := MWHandlerTiming new
		                 handler: handlerMemoing;
		                 yourself.

	result := (MWDecorator withAllImplementations: { 
				           (Collection >> #doª:).
				           (Number >> #add:) })
		          do: [ :each | each handler: handlerTiming ];
		          withWrappingDo: [ (1 to: 20) doª: [ :each | each add: 4 ] ].

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter withTreePresenterDo: [ :treePresenter | 
		handlerProfiler addColumnsInPresenter: treePresenter.
		handlerTiming addColumnsInPresenter: treePresenter.

		treePresenter expandAll ].

	presenter openWithSpec.

	self
		assert: tree size equals: 21;
		assert: result equals: (1 to: 20) asArray
]

{ #category : #tests }
MWHandlerTest >> testCountFooSingleWrapper [

	| wrapper handler |
	handler := MWHandlerCounting new.

	wrapper := (MWDecorator on: self class >> #foo)
		           handler: handler;
		           yourself.

	wrapper install.

	self assert:
		(wrapper ifInstalled: [ true ] ifNotInstalled: [ false ]).

	self assert: (self class methodDict at: #foo) equals: wrapper.

	self foo.

	wrapper uninstall.

	self deny: (wrapper ifInstalled: [ true ] ifNotInstalled: [ false ]).

	self assert: handler count equals: 1
]

{ #category : #tests }
MWHandlerTest >> testCountIfTrue [

	| wrappers handler |
	handler := MWHandlerCounting new.

	wrappers := (MWDecorator withAllImplementations:
			             { (Boolean >> #ifTrue:) })
		            do: [ :each | each handler: handler ];
		            yourself.

	wrappers withWrappingDo: [ true ifTrue: [ 3 ] ].

	self assert: handler count equals: 0
]

{ #category : #tests }
MWHandlerTest >> testCountIfTrueDuringSlowFactorial [

	| wrapper wrappers handler ifTrueHandler |
	handler := MWHandlerCounting new.
	ifTrueHandler := MWHandlerCounting new.

	wrapper := (MWDecorator on: Integer >> #slowFactorial)
		           handler: handler;
		           yourself.

	wrappers := (MWDecorator withAllImplementations: { (Boolean >> #ifTrue:) })
		            do: [ :each | each handler: ifTrueHandler ];
		            yourself.

	{ wrapper } , wrappers withWrappingDo: [ 5 slowFactorial ].

	self
		assert: handler count equals: 6;
		assert: ifTrueHandler count equals: 0
]

{ #category : #tests }
MWHandlerTest >> testCountIfTrueSingleWrapper [

	| wrapper handler |
	handler := MWHandlerCounting new.

	wrapper := (MWDecorator on: true class >> #ifTrue:)
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
MWHandlerTest >> testCountIfTrueSingleWrapperWithMethodProxy [

	| wrapper handler |
	handler := MpCountingHandler new.

	wrapper := MpMethodProxy
		           onMethod: true class >> #ifTrue:
		           handler: handler.

	wrapper install.

	self assert: wrapper isEnabled.

	true ifTrue: [ 3 ].

	wrapper uninstall.

	self assert: wrapper isEnabled.

	self assert: handler count equals: 0
]

{ #category : #tests }
MWHandlerTest >> testCountSelfIfTrueSingleWrapper [

	| wrapper handler |
	handler := MWHandlerCounting new.

	wrapper := (MWDecorator on: self class >> #ifTrue:)
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

	| wrapper handler |
	handler := MWHandlerCounting new.

	wrapper := (MWDecorator on: Integer >> #slowFactorial)
		           handler: handler;
		           yourself.

	{ wrapper } withWrappingDo: [ 5 slowFactorial ].

	self assert: handler count equals: 6
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFactorial [

	| wrapper handler tree presenter result |
	tree := CTOrderPreservingTree new.

	handler := MWHandlerProfiling new
		           tree: tree;
		           yourself.

	wrapper := (MWDecorator on: Integer >> #slowFactorial)
		           handler: handler;
		           yourself.

	result := { wrapper } withWrappingDo: [ 5 slowFactorial ].

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter withTreePresenterDo: [ :treePresenter | 
		handler addColumnsInPresenter: treePresenter.

		treePresenter expandAll ].

	presenter openWithSpec.

	self
		assert: tree size equals: 6;
		assert: result equals: 5 factorial
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFibonacci [

	| wrapper handler tree presenter result handlerTiming |
	tree := CTOrderPreservingTree new.

	handler := MWHandlerProfiling new
		           tree: tree;
		           yourself.

	handlerTiming := MWHandlerTiming new
		                 handler: handler;
		                 yourself.

	wrapper := (MWDecorator on: Integer >> #slowFibonacci)
		           handler: handlerTiming;
		           yourself.

	result := { wrapper } withWrappingDo: [ 10 slowFibonacci ].

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter withTreePresenterDo: [ :treePresenter | 
		handler addColumnsInPresenter: treePresenter.
		handlerTiming addColumnsInPresenter: treePresenter.
		treePresenter expandAll ].
	presenter openWithSpec.

	self
		assert: tree size equals: 177;
		assert: result equals: 11 fibonacciNumbers last
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFibonacciMemoing [

	| wrapper plusWrappers handlerCounting handler tree presenter result handlerProfiler |
	tree := CTOrderPreservingTree new.

	handlerCounting := MWHandlerCounting new.

	handlerProfiler := MWHandlerProfiling new
		                   tree: tree;
		                   yourself.

	handler := MWHandlerMemoing new
		           handler: handlerProfiler;
		           yourself.

	wrapper := (MWDecorator on: Integer >> #slowFibonacci)
		           handler: handler;
		           yourself.

	plusWrappers := (MWDecorator withAllImplementations:
			                 { (Number >> #add:) })
		                do: [ :each | each handler: handlerCounting ];
		                yourself.

	result := { wrapper } , plusWrappers withWrappingDo: [ 
		          10 slowFibonacci ].

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter withTreePresenterDo: [ :treePresenter | 
		handlerProfiler addColumnsInPresenter: treePresenter.

		treePresenter expandAll ].

	presenter openWithSpec.

	self
		assert: tree size equals: 19;
		assert: result equals: 11 fibonacciNumbers last;
		assert: handlerCounting count equals: 9
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFibonacciTailWithAdd [

	| wrapper handler tree presenter result wrapperAdd |
	tree := CTOrderPreservingTree new.

	handler := MWHandlerProfiling new
		           tree: tree;
		           yourself.

	wrapper := (MWDecorator on: Integer >> #slowFibonacci:tail:)
		           handler: handler;
		           yourself.

	wrapperAdd := (MWDecorator on: Number >> #add:)
		              handler: handler;
		              yourself.

	result := { 
		          wrapper.
		          wrapperAdd } withWrappingDo: [ 
		          10 slowFibonacci: 0 tail: 1 ].

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter withTreePresenterDo: [ :treePresenter | 
		handler addColumnsInPresenter: treePresenter.

		treePresenter expandAll ].
	presenter openWithSpec.

	self
		assert: tree size equals: 21;
		assert: result equals: 11 fibonacciNumbers last
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFibonacciWithAdd [

	| wrapper handler tree presenter result wrapperAdd |
	tree := CTOrderPreservingTree new.

	handler := MWHandlerProfiling new
		           tree: tree;
		           yourself.

	wrapper := (MWDecorator on: Integer >> #slowFibonacci)
		           handler: handler;
		           yourself.

	wrapperAdd := (MWDecorator on: Number >> #add:)
		              handler: handler;
		              yourself.

	result := { 
		          wrapper.
		          wrapperAdd } withWrappingDo: [ 10 slowFibonacci ].

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter withTreePresenterDo: [ :treePresenter | 
		handler addColumnsInPresenter: treePresenter.

		treePresenter expandAll ].
	presenter openWithSpec.

	self
		assert: tree size equals: 265;
		assert: result equals: 11 fibonacciNumbers last " 55"
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFibonacciWithAddOnly [

	| handler tree presenter result wrapperAdd |
	tree := CTOrderPreservingTree new.

	handler := MWHandlerProfiling new
		           tree: tree;
		           yourself.

	wrapperAdd := (MWDecorator on: Number >> #add:)
		              handler: handler;
		              yourself.

	result := { wrapperAdd } withWrappingDo: [ 10 slowFibonacci ].

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter withTreePresenterDo: [ :treePresenter | 
		handler addColumnsInPresenter: treePresenter.

		treePresenter expandAll ].
	presenter openWithSpec.

	self
		assert: tree size equals: 88;
		assert: result equals: 11 fibonacciNumbers last " 55"
]

{ #category : #tests }
MWHandlerTest >> testSequenceableCollectionMergeSort [

	| handlerTiming handlerMemoing tree presenter result handlerProfiler |
	tree := CTOrderPreservingTree new.

	handlerProfiler := MWHandlerProfiling new
		                   tree: tree;
		                   yourself.

	handlerMemoing := MWHandlerMemoing new
		                  handler: handlerProfiler;
		                  yourself.

	handlerTiming := MWHandlerTiming new
		                 handler: handlerMemoing;
		                 yourself.

	result := (MWDecorator withAllImplementations: { 
				           (SequenceableCollection
				            >> #mergeFirst:middle:last:into:by:).
				           (SequenceableCollection
				            >> #mergeSortFrom:to:src:dst:by:) })
		          do: [ :each | each handler: handlerTiming ];
		          withWrappingDo: [ (1 to: 20) shuffled sort ].


	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter withTreePresenterDo: [ :treePresenter | 
		handlerProfiler addColumnsInPresenter: treePresenter.
		handlerTiming addColumnsInPresenter: treePresenter.

		treePresenter expandAll ].

	presenter openWithSpec.

	self
		assert: tree size equals: 58;
		assert: result equals: (1 to: 20) asArray
]

{ #category : #tests }
MWHandlerTest >> testTimingSlowFibonacciMemoing [

	| wrapper plusWrappers handlerTiming handlerMemoing tree presenter result handlerProfiler |
	tree := CTOrderPreservingTree new.

	handlerProfiler := MWHandlerProfiling new
		                   tree: tree;
		                   yourself.

	handlerMemoing := MWHandlerMemoing new
		                  handler: handlerProfiler;
		                  yourself.

	handlerTiming := MWHandlerTiming new
		                 handler: handlerMemoing;
		                 yourself.

	wrapper := (MWDecorator on: Integer >> #slowFibonacci)
		           handler: handlerTiming;
		           yourself.

	plusWrappers := (MWDecorator withAllImplementations:
			                 { (Number >> #add:) })
		                do: [ :each | each handler: handlerTiming ];
		                yourself.

	result := { wrapper } withWrappingDo: [ 10 slowFibonacci ]. ", plusWrappers"

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter withTreePresenterDo: [ :treePresenter | 
		handlerProfiler addColumnsInPresenter: treePresenter.
		handlerTiming addColumnsInPresenter: treePresenter.

		treePresenter expandAll ].

	presenter openWithSpec.

	self
		assert: tree size equals: 19;
		assert: result equals: 11 fibonacciNumbers last
]
