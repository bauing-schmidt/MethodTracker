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

	| wrapper handler tree presenter result |
	tree := CTOrderPreservingTree new.

	handler := MWHandlerProfiling new
		           tree: tree;
		           yourself.

	wrapper := (AbstractMethodWrapper on: Integer >> #slowFactorial)
		           handler: handler;
		           yourself.

	result := { wrapper } withWrappingDo: [ 5 slowFactorial ].

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter treePresenter display: [ :aContext | 
		aContext receiver asString , ' ' , aContext selector ].

	presenter openWithSpec.

	self
		assert: tree size equals: 7;
		assert: result equals: 5 factorial
]
