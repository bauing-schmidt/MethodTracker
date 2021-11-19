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

	| ctx wrapper handler tree presenter result start timespan |
	tree := CTOrderPreservingTree new.

	handler := MWHandlerProfiling new
		           tree: tree;
		           yourself.

	wrapper := (MWDecorator on: Integer >> #slowFactorial)
		           handler: handler;
		           yourself.

	start := DateAndTime now.
	result := { wrapper } withWrappingDo: [ 
		          ctx := thisContext.
		          5 slowFactorial ].
	timespan := Timespan
		            starting: start
		            duration: DateAndTime now - start.

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter treePresenter
		display: [ :aContext | 
			handler at: aContext ifAbsent: [ 
					| messageSend |
					messageSend := (RSFullMessageSend
						                receiver: ctx receiver
						                selector: ctx selector
						                arguments: ctx arguments) yourself.
					" client: ctx client;
						               callerSelector: ctx sender selector;"

					timespan -> messageSend ] ];
		expandAll.

	presenter openWithSpec.

	self
		assert: tree size equals: 6;
		assert: result equals: 5 factorial
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFibonacci [

	| ctx wrapper handler tree presenter result start timespan receiver |
	tree := CTOrderPreservingTree new.

	handler := MWHandlerProfiling new
		           tree: tree;
		           yourself.

	wrapper := (MWDecorator on: Integer >> #slowFibonacci)
		           handler: handler;
		           yourself.

	receiver := 10.

	start := DateAndTime now.
	result := { wrapper } withWrappingDo: [ 
		          ctx := thisContext.
		          receiver slowFibonacci ].
	timespan := Timespan
		            starting: start
		            duration: DateAndTime now - start.

	"handler adjustTree."

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter treePresenter
		display: [ :aContext | 
			aContext receiver asString , ' ' , aContext methodSelector ];
		expandAll.

	presenter openWithSpec.


	self
		assert: tree size equals: 89;
		assert: result equals: (receiver + 1) fibonacciNumbers last
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFibonacciMemoing [

	| ctx wrapper handler tree presenter result start timespan receiver handlerProfiler |
	tree := CTOrderPreservingTree new.

	handlerProfiler := MWHandlerProfiling new
		                   tree: tree;
		                   yourself.

	handler := MWHandlerMemoing new
		           handler: handlerProfiler;
		           yourself.

	wrapper := (MWDecorator on: Integer >> #slowFibonacci)
		           handler: handler;
		           yourself.

	receiver := 10.

	start := DateAndTime now.
	result := { wrapper } withWrappingDo: [ 
		          ctx := thisContext.
		          receiver slowFibonacci ].
	timespan := Timespan
		            starting: start
		            duration: DateAndTime now - start.

"	handlerProfiler adjustTree."

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter treePresenter
		display: [ :aContext | 
			aContext receiver asString , ' ' , aContext method selector
			"handlerProfiler at: aContext ifAbsent: [ 
					| messageSend |
					messageSend := (RSFullMessageSend
						                receiver: ctx receiver
						                selector: ctx selector
						                arguments: ctx arguments) yourself.
					"" client: ctx client;
						               callerSelector: ctx sender selector;""

					timespan -> messageSend ] " ];
		expandAll.

	presenter openWithSpec.


	self
		assert: tree size equals: 10;
		assert: result equals: (receiver + 1) fibonacciNumbers last
]
