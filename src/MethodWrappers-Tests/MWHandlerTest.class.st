"
A MWHandlerTest is a test class for testing the behavior of MWHandler
"
Class {
	#name : #MWHandlerTest,
	#superclass : #TestCase,
	#category : #'MethodWrappers-Tests'
}

{ #category : #tests }
MWHandlerTest >> testCountSlowFactorial [

	| wrapper handler |
	handler := MWHandlerCounting new.

	wrapper := (AbstractMethodWrapper on: Integer >> #slowFactorial)
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

	wrapper := (AbstractMethodWrapper on: Integer >> #slowFactorial)
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

	presenter treePresenter display: [ :aContext | 
		handler at: aContext ifAbsent: [ 
			| messageSend |
			messageSend := (RSFullMessageSend
				                receiver: ctx receiver
				                selector: ctx selector
				                arguments: ctx arguments) yourself.
			" client: ctx client;
						               callerSelector: ctx sender selector;"

			timespan -> messageSend ] ].

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

	wrapper := (AbstractMethodWrapper on: Integer >> #slowFibonacci)
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

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter treePresenter
		display: [ :aContext | 
			handler at: aContext ifAbsent: [ 
					| messageSend |
					messageSend := (RSFullMessageSend
						                receiver: ctx receiver
						                selector: ctx selector
						                arguments: ctx arguments)
						              " client: ctx client;
						               callerSelector: ctx sender selector;"
						               yourself.

					timespan -> messageSend ] ];
		expandAll.

	presenter openWithSpec.


	self
		assert: tree size equals: 178;
		assert: result equals: (receiver + 1) fibonacciNumbers last
]
