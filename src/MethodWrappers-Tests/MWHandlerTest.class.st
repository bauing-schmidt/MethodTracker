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

	| wrapper handler tree |
	tree := CTOrderPreservingTree new.

	handler := MWHandlerProfiling new
		           tree: tree;
		           yourself.

	wrapper := (AbstractMethodWrapper on: Integer >> #slowFactorial)
		           handler: handler;
		           yourself.

	{ wrapper } withWrappingDo: [ 5 slowFactorial ].

	(CTOrderPreservingTreePresenter on: tree) openWithSpec.

	self assert: tree size equals: 7
]
