"
A MWHandlerTest is a test class for testing the behavior of MWHandler
"
Class {
	#name : #MWHandlerTest,
	#superclass : #TestCase,
	#category : #'MethodWrappers-Tests'
}

{ #category : #tests }
MWHandlerTest >> testCountIfTrue [

	| wrappers handler |
	handler := MWHandlerCounting new.

	wrappers := (MWBehavior withAllImplementations:
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

	wrapper := (MWBehavior on: Integer >> #slowFactorial)
		           handler: handler;
		           yourself.

	wrappers := (MWBehavior withAllImplementations: { (Boolean >> #ifTrue:) })
		            do: [ :each | each handler: ifTrueHandler ];
		            yourself.

	{ wrapper } , wrappers withWrappingDo: [ 5 slowFactorial ].

	self
		assert: handler count equals: 6;
		assert: ifTrueHandler count equals: 0
]

{ #category : #tests }
MWHandlerTest >> testCountSlowFactorial [

	| wrapper handler |
	handler := MWHandlerCounting new.

	wrapper := (MWBehavior on: Integer >> #slowFactorial)
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

	wrapper := (MWBehavior on: Integer >> #slowFactorial)
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
		assert: tree size equals: 7;
		assert: result equals: 5 factorial
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFibonacci [

	| ctx wrapper handler tree presenter result start timespan receiver |
	tree := CTOrderPreservingTree new.

	handler := MWHandlerProfiling new
		           tree: tree;
		           yourself.

	wrapper := (MWBehavior on: Integer >> #slowFibonacci)
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
			aContext receiver asString , ' ' , aContext methodSelector "
			handler at: aContext ifAbsent: [ 
					| messageSend |
					messageSend := (RSFullMessageSend
						                receiver: ctx receiver
						                selector: ctx selector
						                arguments: ctx arguments)
						              "" client: ctx client;
						               callerSelector: ctx sender selector;""
						               yourself.

					timespan -> messageSend ]" ];
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

	wrapper := (MWBehavior on: Integer >> #slowFibonacci)
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

	handlerProfiler adjustTree.

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
		assert: tree size equals: 13;
		assert: result equals: (receiver + 1) fibonacciNumbers last
]
