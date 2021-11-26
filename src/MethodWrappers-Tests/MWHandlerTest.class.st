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

	"
(MWHandlerObjectCentric forKindOf: Interval)


	wrappers := (MWDecoratorCollection withAllImplementations: { 
			           (Collection >> #do:) 
			           (Number >> #add:) }) withHandlers: {  handlerCentric . nil}.
			
	wrappers do: [ :each | each handler: handlerCentric ].
	
   [ interval do: [ :each | each add: 4 ] ] valueWithWrapping: wrappers.

	[ wrappers do: [ :each | each install ] ] value:    [ interval do: [ :each | each add: 4 ] ] then: 	[ wrappers do: [ :each | each uninstall ] ]."

	| handlerTiming tree presenter result handlerProfiler handlerCentric interval |
	tree := CTOrderPreservingTree new.

	handlerProfiler := MWHandlerExecution new
		                   tree: tree;
		                   yourself.

	handlerTiming := MWHandlerTiming new
		                 handler: handlerProfiler;
		                 yourself.

	interval := 1 to: 20.

	handlerCentric := MWHandlerObjectCentric new
		                  predicate: [ :recv :args | 
			                  recv == interval or: [ recv even ] ];
		                  handler: handlerTiming;
		                  yourself.

	result := (MWDecoratorCollection withAllImplementations: { 
				           (Collection >> #do:).
				           (Number >> #add:) })
		          do: [ :each | each handler: handlerCentric ];
		          withWrappingDo: [ interval do: [ :each | each add: 4 ] ].

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter withTreePresenterDo: [ :treePresenter | 
		| metadata |
		metadata := IdentityDictionary new.

		handlerProfiler
			addColumnsInPresenter: treePresenter
			metadata: metadata.
		handlerTiming
			addColumnsInPresenter: treePresenter
			metadata: metadata.

		treePresenter expandAll ].

	presenter openWithSpec.

	self
		assert: tree size equals: 11;
		assert: result equals: (1 to: 20) asArray
]

{ #category : #tests }
MWHandlerTest >> testAddWithinDoª [

	| handlerTiming tree presenter result handlerProfiler |
	tree := CTOrderPreservingTree new.

	handlerProfiler := MWHandlerExecution new
		                   tree: tree;
		                   yourself.

	handlerTiming := MWHandlerTiming new
		                 handler: handlerProfiler;
		                 yourself.

	result := (MWDecoratorCollection withAllImplementations: { 
				           (Collection >> #doª:).
				           (Number >> #add:) })
		          do: [ :each | each handler: handlerTiming ];
		          withWrappingDo: [ 
			          (1 to: 20) doª: [ :each | each add: 4 ].
			          (1 to: 5) doª: [ :each | each - 4 ] ].

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter withTreePresenterDo: [ :treePresenter | 
		| metadata |
		metadata := IdentityDictionary new.

		handlerProfiler
			addColumnsInPresenter: treePresenter
			metadata: metadata.
		handlerTiming
			addColumnsInPresenter: treePresenter
			metadata: metadata.

		treePresenter expandAll ].

	presenter openWithSpec.

	self
		assert: tree size equals: 22;
		assert: result equals: (1 to: 5) asArray
]

{ #category : #tests }
MWHandlerTest >> testCountAdd [

	| wrappers handler |
	handler := MWHandlerCounting new.

	wrappers := (MWDecoratorCollection withAllImplementations:
			             { (Number >> #add:) })
		            do: [ :each | each handler: handler ];
		            yourself.

	wrappers withWrappingDo: [ 
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
		           owner: (Maybe just: nil);
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

	| wrappers handler |
	handler := MWHandlerCounting new.

	wrappers := (MWDecoratorCollection withAllImplementations:
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

	wrapper := MWDecorator new
		           compiledMethod: Integer >> #slowFactorial;
		           handler: handler;
		           yourself.

	wrappers := (MWDecoratorCollection withAllImplementations:
			             { (Boolean >> #ifTrue:) })
		            do: [ :each | each handler: ifTrueHandler ];
		            add: wrapper;
		            yourself.

	wrappers withWrappingDo: [ 5 slowFactorial ].

	self
		assert: handler count equals: 6;
		assert: ifTrueHandler count equals: 0
]

{ #category : #tests }
MWHandlerTest >> testCountIfTrueSingleWrapper [

	| wrapper handler |
	handler := MWHandlerCounting new.

	wrapper := MWDecorator new
		           owner: (Maybe just: nil);
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
		           owner: (Maybe just: nil);
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

	| wrapper handler |
	handler := MWHandlerCounting new.

	wrapper := MWDecorator new
		           owner: (Maybe just: nil);
		           compiledMethod: Integer >> #slowFactorial;
		           handler: handler;
		           yourself.

	{ wrapper } withWrappingDo: [ 5 slowFactorial ].

	self assert: handler count equals: 6
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFactorial [

	| wrapper handler tree presenter result |
	tree := CTOrderPreservingTree new.

	handler := MWHandlerExecution new
		           tree: tree;
		           yourself.

	wrapper := MWDecorator new
		           owner: (Maybe just: nil);
		           compiledMethod: Integer >> #slowFactorial;
		           handler: handler;
		           yourself.

	result := { wrapper } withWrappingDo: [ 5 slowFactorial ].

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter withTreePresenterDo: [ :treePresenter | 
		| metadata |
		metadata := IdentityDictionary new.

		handler addColumnsInPresenter: treePresenter metadata: metadata.

		treePresenter expandAll ].

	presenter openWithSpec.

	self
		assert: tree size equals: 6;
		assert: result equals: 5 factorial
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFibonacci [

	| wrapper handlerExecution tree presenter result handlerTiming |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerExecution new
		                    tree: tree;
		                    yourself.

	handlerTiming := MWHandlerTiming new
		                 handler: handlerExecution;
		                 yourself.

	wrapper := MWDecorator new
		           owner: (Maybe just: nil);
		           compiledMethod: Integer >> #slowFibonacci;
		           handler: handlerTiming;
		           yourself.

	result := { wrapper } withWrappingDo: [ 10 slowFibonacci ].

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter withTreePresenterDo: [ :treePresenter | 
		| metadata |
		metadata := IdentityDictionary new.

		handlerExecution
			addColumnsInPresenter: treePresenter
			metadata: metadata.

		handlerTiming
			addColumnsInPresenter: treePresenter
			metadata: metadata.

		treePresenter whenSelectionChangedDo: [ :selectedItem | 
			presenter treeShown in: [ :treeShown | 
				self sequenceDiagramTree: treeShown metadata: metadata ] ].

		treePresenter expandAll ].

	presenter openWithSpec.

	self
		assert: tree size equals: 177;
		assert: result equals: 11 fibonacciNumbers last
]

{ #category : #tests }
MWHandlerTest >> testProfileSlowFibonacciMemoing [

	| wrapper wrappers handlerCounting handler tree presenter result handlerExecution |
	tree := CTOrderPreservingTree new.

	handlerCounting := MWHandlerCounting new.

	handlerExecution := MWHandlerExecution new
		                    tree: tree;
		                    yourself.

	handler := MWHandlerMemoing new
		           handler: handlerExecution;
		           yourself.

	wrapper := MWDecorator new
		           compiledMethod: Integer >> #slowFibonacci;
		           handler: handler;
		           yourself.

	wrappers := (MWDecoratorCollection withAllImplementations:
			             { (Number >> #add:) })
		            do: [ :each | each handler: handlerCounting ];
		            yourself.

	wrappers add: wrapper.

	result := wrappers withWrappingDo: [ 10 slowFibonacci ].

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter withTreePresenterDo: [ :treePresenter | 
		| metadata |
		metadata := IdentityDictionary new.

		handlerExecution
			addColumnsInPresenter: treePresenter
			metadata: metadata.

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

	handler := MWHandlerExecution new
		           tree: tree;
		           yourself.

	wrapper := MWDecorator new
		           compiledMethod: Integer >> #slowFibonacci:tail:;
		           handler: handler;
		           yourself.

	wrapperAdd := MWDecorator new
		              compiledMethod: Number >> #add:;
		              handler: handler;
		              yourself.

	result := MWDecoratorCollection new
		          add: wrapper;
		          add: wrapperAdd;
		          withWrappingDo: [ 10 slowFibonacci: 0 tail: 1 ].

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter withTreePresenterDo: [ :treePresenter | 
		| metadata |
		metadata := IdentityDictionary new.

		handler addColumnsInPresenter: treePresenter metadata: metadata.

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

	handler := MWHandlerExecution new
		           tree: tree;
		           yourself.

	wrapper := MWDecorator new
		           compiledMethod: Integer >> #slowFibonacci;
		           handler: handler;
		           yourself.

	wrapperAdd := MWDecorator new
		              compiledMethod: Number >> #add:;
		              handler: handler;
		              yourself.

	result := result := MWDecoratorCollection new
		                    add: wrapper;
		                    add: wrapperAdd;
		                    withWrappingDo: [ 10 slowFibonacci ].

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter withTreePresenterDo: [ :treePresenter | 
		| metadata |
		metadata := IdentityDictionary new.

		handler addColumnsInPresenter: treePresenter metadata: metadata.

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

	handler := MWHandlerExecution new
		           tree: tree;
		           yourself.

	wrapperAdd := MWDecorator new
		              compiledMethod: Number >> #add:;
		              handler: handler;
		              yourself.

	result := MWDecoratorCollection new
		          add: wrapperAdd;
		          withWrappingDo: [ 10 slowFibonacci ].

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter withTreePresenterDo: [ :treePresenter | 
		| metadata |
		metadata := IdentityDictionary new.

		handler addColumnsInPresenter: treePresenter metadata: metadata.

		treePresenter expandAll ].
	presenter openWithSpec.

	self
		assert: tree size equals: 88;
		assert: result equals: 11 fibonacciNumbers last " 55"
]

{ #category : #tests }
MWHandlerTest >> testSequenceableCollectionMergeSort [

	| handlerTiming tree presenter result handlerExecution |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerExecution new
		                    tree: tree;
		                    yourself.

	handlerTiming := MWHandlerTiming new
		                 handler: handlerExecution;
		                 yourself.

	result := (MWDecoratorCollection withAllImplementations: { 
				           (SequenceableCollection >> #sort).
				           (SequenceableCollection >> #mergeSortFrom:to:by:).
				           (SequenceableCollection
				            >> #mergeFirst:middle:last:into:by:).
				           (SequenceableCollection
				            >> #mergeSortFrom:to:src:dst:by:).
				           (SequenceableCollection
				            >> #replaceFrom:to:with:startingAt:) })
		          do: [ :each | each handler: handlerTiming ];
		          withWrappingDo: [ (1 to: 20) shuffled sort ].

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter withTreePresenterDo: [ :treePresenter | 
		| metadata |
		metadata := IdentityDictionary new.

		handlerExecution
			addColumnsInPresenter: treePresenter
			metadata: metadata.

		handlerTiming
			addColumnsInPresenter: treePresenter
			metadata: metadata.

		treePresenter whenSelectionChangedDo: [ :selectedItem | 
			presenter treeShown in: [ :treeShown | 
				self sequenceDiagramTree: treeShown metadata: metadata ] ].

		treePresenter expandAll ].

	presenter openWithSpec.

	self
		assert: tree size equals: 81;
		assert: result equals: (1 to: 20) asArray
]

{ #category : #tests }
MWHandlerTest >> testSequenceableCollectionMergeSortCopying [

	| handlerTiming tree presenter result handlerExecution handlerCopying |
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

	result := (MWDecoratorCollection withAllImplementations: { 
				           (SequenceableCollection >> #sort).
				           (SequenceableCollection >> #mergeSortFrom:to:by:).
				           (SequenceableCollection
				            >> #mergeFirst:middle:last:into:by:).
				           (SequenceableCollection
				            >> #mergeSortFrom:to:src:dst:by:).
				           (SequenceableCollection
				            >> #replaceFrom:to:with:startingAt:) })
		          do: [ :each | each handler: handlerCopying ];
		          withWrappingDo: [ (1 to: 20) shuffled sort ].

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter withTreePresenterDo: [ :treePresenter | 
		| metadata |
		metadata := IdentityDictionary new.

		handlerExecution
			addColumnsInPresenter: treePresenter
			metadata: metadata.

		handlerCopying
			addColumnsInPresenter: treePresenter
			metadata: metadata.

		handlerTiming
			addColumnsInPresenter: treePresenter
			metadata: metadata.

		treePresenter whenSelectionChangedDo: [ :selectedItem | 
			presenter treeShown in: [ :treeShown | 
				self sequenceDiagramTree: treeShown metadata: metadata ] ].

		treePresenter expandAll ].

	presenter openWithSpec.

	self
		assert: tree size equals: 81;
		assert: result equals: (1 to: 20) asArray
]

{ #category : #tests }
MWHandlerTest >> testSequenceableCollectionMergeSortCopyingDetailed [

	| handlerTiming tree presenter result handlerExecution handlerCopying |
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

	result := (MWDecoratorCollection withAllImplementations: { 
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
		          withWrappingDo: [ (1 to: 20) shuffled sort ].

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter withTreePresenterDo: [ :treePresenter | 
		| metadata |
		metadata := IdentityDictionary new.

		handlerExecution
			addColumnsInPresenter: treePresenter
			metadata: metadata.

		handlerCopying
			addColumnsInPresenter: treePresenter
			metadata: metadata.

		handlerTiming
			addColumnsInPresenter: treePresenter
			metadata: metadata.

		treePresenter whenSelectionChangedDo: [ :selectedItem | 
			presenter treeShown in: [ :treeShown | 
				self sequenceDiagramTree: treeShown metadata: metadata ] ].

		treePresenter expandAll ].

	presenter openWithSpec.

	self
		assert: tree size equals: 103;
		assert: result equals: (1 to: 20) asArray
]

{ #category : #tests }
MWHandlerTest >> testSequenceableCollectionMergeSortPlugging [

	| handlerTiming tree presenter result handlerExecution handlerBlockPlugging |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerExecution new
		                    tree: tree;
		                    yourself.

	handlerBlockPlugging := MWHandlerSuspendPlugging new
		                        handler: handlerExecution;
		                        blockClosure: [ :aLink | 
			                        (1 to: 20) shuffled sort ];
		                        yourself.

	handlerTiming := MWHandlerTiming new
		                 handler: handlerBlockPlugging;
		                 yourself.

	result := (MWDecoratorCollection withAllImplementations: { 
				           (SequenceableCollection >> #sort).
				           (SequenceableCollection >> #mergeSortFrom:to:by:).
				           (SequenceableCollection
				            >> #mergeFirst:middle:last:into:by:).
				           (SequenceableCollection
				            >> #mergeSortFrom:to:src:dst:by:).
				           (SequenceableCollection
				            >> #replaceFrom:to:with:startingAt:) })
		          do: [ :each | each handler: handlerTiming ];
		          withWrappingDo: [ (1 to: 20) shuffled sort ].

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter withTreePresenterDo: [ :treePresenter | 
		| metadata |
		metadata := IdentityDictionary new.

		handlerExecution
			addColumnsInPresenter: treePresenter
			metadata: metadata.

		handlerTiming
			addColumnsInPresenter: treePresenter
			metadata: metadata.

		treePresenter whenSelectionChangedDo: [ :selectedItem | 
			presenter treeShown in: [ :treeShown | 
				self sequenceDiagramTree: treeShown metadata: metadata ] ].

		treePresenter expandAll ].

	presenter openWithSpec.

	self
		assert: tree size equals: 81;
		assert: result equals: (1 to: 20) asArray
]

{ #category : #tests }
MWHandlerTest >> testTimingSlowFibonacciMemoing [

	| wrapper plusWrappers handlerTiming handlerMemoing tree presenter result handlerProfiler |
	tree := CTOrderPreservingTree new.

	handlerProfiler := MWHandlerExecution new
		                   tree: tree;
		                   yourself.

	handlerMemoing := MWHandlerMemoing new
		                  handler: handlerProfiler;
		                  yourself.

	handlerTiming := MWHandlerTiming new
		                 handler: handlerMemoing;
		                 yourself.

	wrapper := MWDecorator new
		           compiledMethod: Integer >> #slowFibonacci;
		           handler: handlerTiming;
		           yourself.

	plusWrappers := (MWDecoratorCollection withAllImplementations:
			                 { (Number >> #add:) })
		                do: [ :each | each handler: handlerTiming ];
		                yourself.

	result := MWDecoratorCollection new
		          add: wrapper;
		          withWrappingDo: [ 10 slowFibonacci ]. ", plusWrappers"

	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter withTreePresenterDo: [ :treePresenter | 
		| metadata |
		metadata := IdentityDictionary new.

		handlerProfiler
			addColumnsInPresenter: treePresenter
			metadata: metadata.
		handlerTiming
			addColumnsInPresenter: treePresenter
			metadata: metadata.

		treePresenter expandAll ].

	presenter openWithSpec.

	self
		assert: tree size equals: 19;
		assert: result equals: 11 fibonacciNumbers last
]
