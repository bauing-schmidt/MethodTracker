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
MWHandlerTest >> sequenceDiagramTree: aTree metadata: metadata [

	| builder shapes orderedCalls |
	shapes := OrderedCollection new.

	orderedCalls := OrderedCollection new.

	aTree
		pre: [ :each | 
			| messageSend ctx ctxParent span model |
			ctx := each asContextReifiedFromWrapping.
			ctxParent := aTree parent: each ifAbsent: [ Error signal ].
			model := metadata at: each.

			messageSend := (RSFullMessageSend
				                receiver: ctx receiver
				                selector: ctx selector
				                arguments: ctx arguments)
				               client:
					               ctxParent asContextReifiedFromWrapping receiver;
				               callerSelector:
					               ctxParent asContextReifiedFromWrapping selector;
				               yourself.

			span := TimespanDiscrete new
				        start: model startTime asDateAndTime;
				        duration: model duration;
				        logicalStart: model visit x;
				        logicalDuration: model visitDuration;
				        yourself.

			span -> messageSend yourself: [ :anAssoc | 
				orderedCalls add: anAssoc ] ]
		post: [ :each :anAssoc | 
			anAssoc value in: [ :fullMessageSend | 
				| returnMessageSend return |
				return := (metadata at: each) return.

				returnMessageSend := fullMessageSend asReturnMessageSend
					                     return: return;
					                     yourself.
				fullMessageSend
					ifSelfSend: [ anAssoc value: returnMessageSend ]
					ifNotSelfSend: [ 
						| timespan returnTimespan |
						timespan := anAssoc key.

						returnTimespan := TimespanDiscrete new
							                  start: timespan end;
							                  duration: Duration zero;
							                  logicalStart: timespan logicalStart;
							                  logicalDuration: timespan logicalDuration.

						orderedCalls add: returnTimespan -> returnMessageSend ] ] ].

	builder := RSUMLSequenceBuilder new
		           objectsSeenSoFar: IdentityDictionary new;
		           messagesSends: orderedCalls;
		           previousHeaders: OrderedCollection new;
		           previousMessagesSends: OrderedCollection new;
		           build;
		           yourself.

	shapes add: builder canvas asShape.

	RSVerticalLineLayout new
		verticalGap: -5;
		alignLeft;
		on: shapes.

	RSCanvas new
		addAll: shapes;
		zoomToFit;
		"in: [ :c | 
			c svgExporter
				zoomToShapes;
				export ];"
		addInteraction: RSCanvasController new;
		open
]

{ #category : #tests }
MWHandlerTest >> testAddWithinDoObjectCentric [

	| handlerTiming tree metadata result handlerExecution handlerCentric interval |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerExecution new
		                    tree: tree;
		                    yourself.

	handlerTiming := MWHandlerTiming new
		                 handler: handlerExecution;
		                 yourself.

	interval := 1 to: 20.

	handlerCentric := MWHandlerObjectCentric new
		                  predicate: [ :recv :args | 
			                  recv == interval or: [ recv even ] ];
		                  handler: handlerTiming;
		                  yourself.

	result := (MWSession withAllImplementations: { 
				           (Collection >> #do:).
				           (Number >> #add:) })
		          do: [ :each | each handler: handlerCentric ];
		          value: [ interval do: [ :each | each add: 4 ] ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerTiming metadata: metadata.

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 11;
		assert: result equals: (1 to: 20) asArray
]

{ #category : #tests }
MWHandlerTest >> testAddWithinDoª [

	| handlerTiming tree metadata result handlerExecution |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerExecution new
		                    tree: tree;
		                    yourself.

	handlerTiming := MWHandlerTiming new
		                 handler: handlerExecution;
		                 yourself.

	result := (MWSession withAllImplementations: { 
				           (Collection >> #doª:).
				           (Number >> #add:) })
		          do: [ :each | each handler: handlerTiming ];
		          value: [ 
			          (1 to: 20) doª: [ :each | each add: 4 ].
			          (1 to: 5) doª: [ :each | each - 4 ] ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerTiming metadata: metadata.

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

	self assert: handler count equals: 1
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
MWHandlerTest >> testProfileSlowFactorial [

	| result tree metadata handlerExecution handlerTiming|
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerExecution new
		                    tree: tree;
		                    yourself.

	handlerTiming := MWHandlerTiming new
		                 handler: handlerExecution;
		                 yourself.

	result := MWSession new
		          add: (MWDecorator new
				           compiledMethod: Integer >> #slowFactorial;
				           handler: handlerTiming;
				           yourself);
		          value: [ 5 slowFactorial ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerTiming metadata: metadata.

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 6;
		assert: result equals: 5 factorial
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFibonacci [

	| handlerExecution tree metadata result handlerTiming |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerExecution new
		                    tree: tree;
		                    yourself.

	handlerTiming := MWHandlerTiming new
		                 handler: handlerExecution;
		                 yourself.

	result := MWSession new
		          add: (MWDecorator new
				           compiledMethod: Integer >> #slowFibonacci;
				           handler: handlerTiming;
				           yourself);
		          value: [ 10 slowFibonacci ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerTiming metadata: metadata.

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 177;
		assert: result equals: 11 fibonacciNumbers last
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFibonacciMemoing [

	| handlerCounting handler tree handlerTiming result handlerExecution metadata |
	tree := CTOrderPreservingTree new.

	handlerCounting := MWHandlerCounting new.

	handlerExecution := MWHandlerExecution new
		                    tree: tree;
		                    yourself.

	handlerTiming := MWHandlerTiming new
		                 handler: handlerExecution;
		                 yourself.

	handler := MWHandlerMemoing new
		           handler: handlerTiming;
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
	handlerTiming metadata: metadata.

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 19;
		assert: result equals: 11 fibonacciNumbers last;
		assert: handlerCounting count equals: 9
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFibonacciTailWithAdd [

	| wrapper handlerExecution tree metadata result wrapperAdd handlerTiming |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerExecution new
		                    tree: tree;
		                    yourself.

	handlerTiming := MWHandlerTiming new
		                 handler: handlerExecution;
		                 yourself.

	wrapper := MWDecorator new
		           compiledMethod: Integer >> #slowFibonacci:tail:;
		           handler: handlerTiming;
		           yourself.

	wrapperAdd := MWDecorator new
		              compiledMethod: Number >> #add:;
		              handler: handlerTiming;
		              yourself.

	result := MWSession new
		          add: wrapper;
		          add: wrapperAdd;
		          value: [ 10 slowFibonacci: 0 tail: 1 ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerTiming metadata: metadata.

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 21;
		assert: result equals: 11 fibonacciNumbers last
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFibonacciWithAdd [

	| wrapper handlerExecution handlerTiming tree metadata result wrapperAdd |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerExecution new
		                    tree: tree;
		                    yourself.

	handlerTiming := MWHandlerTiming new
		                 handler: handlerExecution;
		                 yourself.

	wrapper := MWDecorator new
		           compiledMethod: Integer >> #slowFibonacci;
		           handler: handlerTiming;
		           yourself.

	wrapperAdd := MWDecorator new
		              compiledMethod: Number >> #add:;
		              handler: handlerTiming;
		              yourself.

	result := MWSession new
		          add: wrapper;
		          add: wrapperAdd;
		          value: [ 10 slowFibonacci ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerTiming metadata: metadata.

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 265;
		assert: result equals: 11 fibonacciNumbers last " 55"
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFibonacciWithAddOnly [

	| handlerExecution handlerTiming tree metadata result wrapperAdd |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerExecution new
		                    tree: tree;
		                    yourself.

	handlerTiming := MWHandlerTiming new
		                 handler: handlerExecution;
		                 yourself.

	wrapperAdd := MWDecorator new
		              compiledMethod: Number >> #add:;
		              handler: handlerTiming;
		              yourself.

	result := MWSession new
		          add: wrapperAdd;
		          value: [ 10 slowFibonacci ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerTiming metadata: metadata.

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 88;
		assert: result equals: 11 fibonacciNumbers last " 55"
]

{ #category : #tests }
MWHandlerTest >> testSequenceableCollectionMergeSort [

	| handlerTiming tree metadata result handlerExecution |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerExecution new
		                    tree: tree;
		                    yourself.

	handlerTiming := MWHandlerTiming new
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
		          do: [ :each | each handler: handlerTiming ];
		          value: [ (1 to: 20) shuffled sort ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerTiming metadata: metadata.

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 81;
		assert: result equals: (1 to: 20) asArray
]

{ #category : #tests }
MWHandlerTest >> testSequenceableCollectionMergeSortCopying [

	| handlerTiming tree result handlerExecution handlerCopying metadata |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerExecution new
		                    tree: tree;
		                    yourself.

	handlerTiming := MWHandlerTiming new
		                 handler: handlerExecution;
		                 yourself.

	handlerCopying := MWHandlerReceiverArgumentsCopying new
		                  handler: handlerTiming;
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
	handlerTiming metadata: metadata.

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 81;
		assert: result equals: (1 to: 20) asArray
]

{ #category : #tests }
MWHandlerTest >> testSequenceableCollectionMergeSortCopyingDetailed [

	| handlerTiming tree metadata result handlerExecution handlerCopying |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerExecution new
		                    tree: tree;
		                    yourself.

	handlerTiming := MWHandlerTiming new
		                 handler: handlerExecution;
		                 yourself.

	handlerCopying := MWHandlerReceiverArgumentsCopying new
		                  handler: handlerTiming;
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
	handlerTiming metadata: metadata.

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 103;
		assert: result equals: (1 to: 20) asArray
]

{ #category : #tests }
MWHandlerTest >> testSequenceableCollectionMergeSortPlugging [

	| handlerTiming tree metadata result handlerExecution handlerBlockPlugging |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerExecution new
		                    tree: tree;
		                    yourself.

	handlerBlockPlugging := MWHandlerSuspendPlugging new
		                        handler: handlerExecution;
		                        blockClosure: [ :session | 
			                        (1 to: 20) shuffled sort ];
		                        yourself.

	handlerTiming := MWHandlerTiming new
		                 handler: handlerBlockPlugging;
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
		          do: [ :each | each handler: handlerTiming ];
		          value: [ (1 to: 20) shuffled sort ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerTiming metadata: metadata.

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 81;
		assert: result equals: (1 to: 20) asArray
]

{ #category : #tests }
MWHandlerTest >> testTimingSlowFibonacciMemoing [

	| handlerTiming handlerMemoing tree metadata result handlerExecution |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerExecution new
		                    tree: tree;
		                    yourself.

	handlerMemoing := MWHandlerMemoing new
		                  handler: handlerExecution;
		                  yourself.

	handlerTiming := MWHandlerTiming new
		                 handler: handlerMemoing;
		                 yourself.

	result := MWSession new
		          add: (MWDecorator new
				           compiledMethod: Integer >> #slowFibonacci;
				           handler: handlerTiming;
				           yourself);
		          value: [ 10 slowFibonacci ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerTiming metadata: metadata.

	"Show here the new presenter."
	(MWSpPresenter on: tree -> metadata) openWithSpec.

	self
		assert: tree size equals: 19;
		assert: result equals: 11 fibonacciNumbers last
]
