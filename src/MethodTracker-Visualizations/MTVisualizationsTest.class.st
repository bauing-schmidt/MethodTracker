Class {
	#name : #MTVisualizationsTest,
	#superclass : #TestCase,
	#traits : 'TIceImagesExporting + MTTProfilingCopying + MTTUmlSequenceDiagramBuilderWithOutliners',
	#classTraits : 'TIceImagesExporting classTrait + MTTProfilingCopying classTrait + MTTUmlSequenceDiagramBuilderWithOutliners classTrait',
	#category : #'MethodTracker-Visualizations'
}

{ #category : #tests }
MTVisualizationsTest >> sutSequenceableCollectionEstrinInit [

	^ { 1. 3. 5. 6. 9 } estrin: 10
]

{ #category : #tests }
MTVisualizationsTest >> sutSequenceableCollectionHornerInit [

	^ { 1. 3. 5. 6 } hornerBase10
]

{ #category : #tests }
MTVisualizationsTest >> testHeapWithAll [

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
			  | presenter tree builder |
			  tree := observedData tree select: [ :aChild :aParent | 
				          aChild == aParent
					          ifTrue: [ 
						          | method |
						          method := aParent asArgumentsReifiedContext method.
						          method = (Heap class >> #withAll:) ]
					          ifFalse: [ true ] ].

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 64;
				  assert: result array
				  equals: #( 1 2 7 3 4 8 11 9 5 6 10 15 17 12 19 20 14 16 13 18 ) ]
]

{ #category : #tests }
MTVisualizationsTest >> testInspectFactorialRecursive [

	| n |
	n := 1 << 4. " 16"

	^ self
		  compiledMethods: { 
				  (Integer >> #factorialRecursive).
				  (Number >> #multiplyNumber:) }
		  wrapping: [ n factorialRecursive ]
		  then: [ :factorial :observedData | 
			  | presenter tree builder |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 33;
				  assert: factorial equals: 20922789888000;
				  assert: factorial equals: n factorial.

			  self
				  assert:
				  (observedData statistics at: Integer >> #factorialRecursive)
					  count
				  equals: 17.

			  self
				  assert:
				  (observedData statistics at: Number >> #multiplyNumber:) count
				  equals: 16.

			  self
				  exportShapeOf: tree
				  accessorBlock: [ :aTree | 
					  aTree
						  asShapeUMLSequenceDiagram: builder
						  metadata: observedData metadata ]
				  pathSuffix: 'sequence-diagram'.

			  self exportSlotsGraphOf: factorial ]
]

{ #category : #tests }
MTVisualizationsTest >> testInspectInversions [

	^ self
		  compiledMethods: { 
				  (SequenceableCollection >> #inversions:).
				  (PositionableStream >> #merge:sortBlock:on:inversionsOrNil:).
				  (SequenceableCollection >> #bisect:baseBlock:).
				  (SequenceableCollection >> #bisect:from:to:baseBlock:).
				  (Stream >> #nextPut:inversion:) }
		  wrapping: [ { 2. 4. 1. 3. 5 } inversions: [ :i :j | i < j ] ]
		  then: [ :inversions :observedData | 
			  | presenter tree builder |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 18;
				  assert: inversions equals: { 
						  (1 -> 2).
						  (1 -> 4).
						  (3 -> 4) }.

			  "The count for #nextPut:inversion: equals the count of inversions."
			  self
				  assert:
				  (observedData statistics at: Stream >> #nextPut:inversion:)
					  count
				  equals: inversions size.

			  self
				  exportShapeOf: tree
				  accessorBlock: [ :aTree | 
					  aTree
						  asShapeUMLSequenceDiagram: builder
						  metadata: observedData metadata ]
				  pathSuffix: 'sequence-diagram'.

			  self exportSlotsGraphOf: inversions ]
]

{ #category : #tests }
MTVisualizationsTest >> testInspectInversionsReversed [

	^ self
		  compiledMethods: { 
				  (SequenceableCollection >> #inversions:).
				  (PositionableStream >> #merge:sortBlock:on:inversionsOrNil:).
				  (SequenceableCollection >> #bisect:baseBlock:).
				  (SequenceableCollection >> #bisect:from:to:baseBlock:).
				  (Stream >> #nextPut:inversion:) }
		  wrapping: [ { 5. 4. 3. 2. 1 } inversions: [ :i :j | i < j ] ]
		  then: [ :inversions :observedData | 
			  | presenter tree builder |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 25;
				  assert: inversions equals: { 
						  (4 -> 5).
						  (3 -> 4).
						  (3 -> 5).
						  (1 -> 2).
						  (1 -> 3).
						  (1 -> 4).
						  (1 -> 5).
						  (2 -> 3).
						  (2 -> 4).
						  (2 -> 5) }.

			  "The count for #nextPut:inversion: equals the count of inversions."
			  self
				  assert:
				  (observedData statistics at: Stream >> #nextPut:inversion:)
					  count
				  equals: inversions size.

			  self
				  exportShapeOf: tree
				  accessorBlock: [ :aTree | 
					  aTree
						  asShapeUMLSequenceDiagram: builder
						  metadata: observedData metadata ]
				  pathSuffix: 'sequence-diagram'.

			  self exportSlotsGraphOf: inversions ]
]

{ #category : #tests }
MTVisualizationsTest >> testInspectKaratsuba42FactorialSquaredProfiled [

	| m |
	m := 42 factorial.

	^ self
		  compiledMethods: { (Integer >> #karatsuba:base:) }
		  wrapping: [ m karatsuba: m base: 10 ]
		  then: [ :large :observedData | 
			  | presenter tree builder nBits leaves |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
				               yourself.

			  nBits := (m numberOfDigitsInBase: 10) + 1.

			  leaves := 0.
			  tree children keysAndValuesDo: [ :aNode :children | 
				  leaves := leaves + children isEmpty asBit ].

			  self
				  assert: tree size equals: 1264;
				  assert: tree size - leaves equals: 421;
				  assert: nBits equals: 53;
				  assert: (nBits ** (3 log: 2)) ceiling equals: 541;
				  assert: large equals: m * m.

			  self exportSlotsGraphOf: large "
				  export: tree
				  pathSuffix: 'sequence-diagram'
				  onCanvasDo: [ :aCanvas :useless | 
					  presenter currentCanvas: aCanvas ];" ]
]

{ #category : #tests }
MTVisualizationsTest >> testInspectLargeIntegerProfiled [

	| m n |
	m := 835.
	n := 714.

	^ self
		  compiledMethods: { 
				  (Integer >> #karatsuba:base:).
				  (Number >> #addNumber:).
				  (Number >> #subtractNumber:).
				  (Number >> #multiplyNumber:) }
		  wrapping: [ m karatsuba: n base: 10 ]
		  then: [ :large :observedData | 
			  | presenter tree builder |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 41;
				  assert: large equals: m * n.

			  self
				  exportShapeOf: tree
				  accessorBlock: [ :aTree | 
					  aTree
						  asShapeUMLSequenceDiagram: builder
						  metadata: observedData metadata ]
				  pathSuffix: 'sequence-diagram'.

			  self exportSlotsGraphOf: large ]
]

{ #category : #tests }
MTVisualizationsTest >> testInspectLargeIntegerQuickProfiled [

	| m n |
	m := 835.
	n := 714.

	^ self
		  compiledMethods: { 
				  (Integer >> #dcMultiplyIntegerQuick:base:).
				  (Integer >> #bitAdd:).
				  (Number >> #subtractNumber:).
				  (Number >> #multiplyNumber:) }
		  wrapping: [ m dcMultiplyIntegerQuick: n base: 10 ]
		  then: [ :large :observedData | 
			  | presenter tree builder |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 41;
				  assert: large equals: m * n.

			  self
				  exportShapeOf: tree
				  accessorBlock: [ :aTree | 
					  aTree
						  asShapeUMLSequenceDiagram: builder
						  metadata: observedData metadata ]
				  pathSuffix: 'sequence-diagram'.

			  self exportSlotsGraphOf: large ]
]

{ #category : #tests }
MTVisualizationsTest >> testInspectLargeIntegerSlowProfiled [

	| m n |
	m := 835.
	n := 714.

	^ self
		  compiledMethods: { 
				  (Integer >> #dcMultiplyIntegerSlow:base:).
				  (Number >> #addNumber:).
				  (Number >> #subtractNumber:).
				  (Number >> #multiplyNumber:) }
		  wrapping: [ m dcMultiplyIntegerSlow: n base: 10 ]
		  then: [ :large :observedData | 
			  | presenter tree builder |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 41;
				  assert: large equals: m * n.

			  self
				  exportShapeOf: tree
				  accessorBlock: [ :aTree | 
					  aTree
						  asShapeUMLSequenceDiagram: builder
						  metadata: observedData metadata ]
				  pathSuffix: 'sequence-diagram'.

			  self exportSlotsGraphOf: large ]
]

{ #category : #tests }
MTVisualizationsTest >> testInspectProbabilisticMedian [

	| n random collection |
	n := 20.
	random := Random seed: 541.
	collection := OrderedCollection new.
	1 to: n do: [ :i | collection add: (random nextInteger: n) ].

	^ self
		  compiledMethods: { 
				  (SequenceableCollection >> #kth:ranking:atRandom:).
				  (SequenceableCollection >> #atRandom:) }
		  wrapping: [ 
			  collection
				  kth: (n / 2) floor
				  ranking: [ :each :pivot | each < pivot ]
				  atRandom: random ]
		  then: [ :median :observedData | 
			  | presenter tree builder |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 8;
				  assert: median equals: (collection sorted at: (n / 2) floor).

			  self
				  exportShapeOf: tree
				  accessorBlock: [ :aTree | 
					  aTree
						  asShapeUMLSequenceDiagram: builder
						  metadata: observedData metadata ]
				  pathSuffix: 'sequence-diagram'.

			  self
				  exportSlotsGraphOf: median;
				  exportSlotsGraphOf: collection pathSuffix: 'original';
				  exportSlotsGraphOf: collection sorted pathSuffix: 'sorted' ]
]

{ #category : #tests }
MTVisualizationsTest >> testInspectProductTo [

	| n |
	n := 1 << 4.

	^ self
		  compiledMethods: { 
				  (Integer >> #productTo:).
				  (Number >> #addNumber:).
				  (Number >> #multiplyNumber:) }
		  wrapping: [ 1 productTo: n ]
		  then: [ :factorial :observedData | 
			  | presenter tree builder |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 21;
				  assert: factorial equals: n factorial.

			  self
				  exportShapeOf: tree
				  accessorBlock: [ :aTree | 
					  aTree
						  asShapeUMLSequenceDiagram: builder
						  metadata: observedData metadata ]
				  pathSuffix: 'sequence-diagram'.

			  self exportSlotsGraphOf: factorial ]
]

{ #category : #tests }
MTVisualizationsTest >> testInspectProductToPropagating [

	| n factorial tree handlerExecution handlerCopying metadata presenter handlerPropagating observedData builder |
	tree := MTContextsTree new.

	handlerExecution := MTHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handlerCopying := MTHandlerReceiverArgumentsCopying new
		                  handler: handlerExecution;
		                  yourself.

	handlerPropagating := MTHandlerSenderPropagating new
		                      handler: handlerCopying;
		                      yourself.

	n := 1 << 4.

	factorial := (MTSession withAllImplementations:
			              { (Number >> #multiplyNumber:) })
		             do: [ :each | each handler: handlerPropagating ];
		             value: [ 1 productTo: n ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerCopying metadata: metadata.

	observedData := MTObservedDataset new
		                tree: tree;
		                metadata: metadata;
		                yourself.

	builder := self umlSequenceDiagramBuilder: RSUMLSequenceBuilder new.

	presenter := (MTOverviewSpPresenter on: observedData)
		             umlSequenceDiagramBuilder: builder;
		             openWithSpec;
		             yourself.

	self
		assert: tree size equals: 18;
		assert: factorial equals: n factorial.

	self
		exportShapeOf: tree
		accessorBlock: [ :aTree | 
			aTree
				asShapeUMLSequenceDiagram: builder
				metadata: observedData metadata ]
		pathSuffix: 'sequence-diagram'.

	self exportSlotsGraphOf: factorial
]

{ #category : #tests }
MTVisualizationsTest >> testProfileSlowExplicitFibonacciTailWithAdd [

	^ self
		  compiledMethods: { 
				  (Integer >> #slowExplicitFibonacci:tail:).
				  (Integer >> #slowExplicitFibonacci:tail:greaterThanZeroIsTrue:).
				  (Integer >> #slowExplicitFibonacci:tail:greaterThanZeroIsFalse:).
				  (Number >> #addNumber:) }
		  wrapping: [ 6 slowExplicitFibonacci: 0 tail: 1 ]
		  then: [ :result :observedData | 
			  | presenter tree builder |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 20;
				  assert: result equals: 6 fibonacciNumbers last.

			  self
				  exportShapeOf: tree
				  accessorBlock: [ :aTree | 
					  aTree
						  asShapeUMLSequenceDiagram: builder
						  metadata: observedData metadata ]
				  pathSuffix: 'sequence-diagram' ]
]

{ #category : #tests }
MTVisualizationsTest >> testProfileSlowFibonacciMemoingWithAdd [

	^ self
		  compiledMethods: { 
				  (Integer >> #slowFibonacciMemo:).
				  (Number >> #addNumber:) }
		  wrapping: [ 6 slowFibonacciMemo: Dictionary new ]
		  then: [ :result :observedData | 
			  | presenter tree builder |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 16;
				  assert: result equals: 7 fibonacciNumbers last.

			  self
				  exportShapeOf: tree
				  accessorBlock: [ :aTree | 
					  aTree
						  asShapeUMLSequenceDiagram: builder
						  metadata: observedData metadata ]
				  pathSuffix: 'sequence-diagram' ]
]

{ #category : #tests }
MTVisualizationsTest >> testProfileSlowFibonacciTailWithAdd [

	^ self
		  compiledMethods: { 
				  (Integer >> #slowFibonacci:tail:).
				  (Number >> #addNumber:) }
		  wrapping: [ 6 slowFibonacci: 0 tail: 1 ]
		  then: [ :result :observedData | 
			  | presenter tree builder |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 13;
				  assert: result equals: 6 fibonacciNumbers last.

			  self
				  exportShapeOf: tree
				  accessorBlock: [ :aTree | 
					  aTree
						  asShapeUMLSequenceDiagram: builder
						  metadata: observedData metadata ]
				  pathSuffix: 'sequence-diagram' ]
]

{ #category : #tests }
MTVisualizationsTest >> testProfileSlowFibonacciWithAdd [

	^ self
		  compiledMethods: { 
				  (Integer >> #slowFibonacci).
				  (Number >> #addNumber:) }
		  wrapping: [ 6 slowFibonacci ]
		  then: [ :result :observedData | 
			  | presenter tree builder |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 37;
				  assert: result equals: 7 fibonacciNumbers last. " 55"

			  self
				  exportShapeOf: tree
				  accessorBlock: [ :aTree | 
					  aTree
						  asShapeUMLSequenceDiagram: builder
						  metadata: observedData metadata ]
				  pathSuffix: 'sequence-diagram' ]
]

{ #category : #tests }
MTVisualizationsTest >> testProfileSlowFibonacciWithAddOnly [

	^ self
		  compiledMethods: { (Number >> #addNumber:) }
		  wrapping: [ 6 slowFibonacci ]
		  then: [ :result :observedData | 
			  | presenter tree builder |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 12;
				  assert: result equals: 7 fibonacciNumbers last. " 55"

			  self
				  exportShapeOf: tree
				  accessorBlock: [ :aTree | 
					  aTree
						  asShapeUMLSequenceDiagram: builder
						  metadata: observedData metadata ]
				  pathSuffix: 'sequence-diagram' ]
]

{ #category : #tests }
MTVisualizationsTest >> testSequenceableCollectionEstrinInit [

	^ self
		  compiledMethods: { 
				  (SequenceableCollection >> #estrin:init:).
				  (Number >> #addNumber:).
				  (Number >> #multiplyNumber:) }
		  wrapping: [ self sutSequenceableCollectionEstrinInit ]
		  then: [ :result :observedData | 
			  | presenter tree builder |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 17;
				  assert: result equals: 13569.

			  self
				  exportShapeOf: tree
				  accessorBlock: [ :aTree | 
					  aTree
						  asShapeUMLSequenceDiagram: builder
						  metadata: observedData metadata ]
				  pathSuffix: 'sequence-diagram'.

			  self exportSlotsGraphOf: result ]
]

{ #category : #tests }
MTVisualizationsTest >> testSequenceableCollectionHornerInit [

	^ self
		  compiledMethods: { 
				  (SequenceableCollection >> #horner:init:).
				  (Number >> #addNumber:).
				  (Number >> #multiplyNumber:) }
		  wrapping: [ self sutSequenceableCollectionHornerInit ]
		  then: [ :result :observedData | 
			  | presenter tree builder |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 9;
				  assert: result equals: 1356.

			  self
				  exportShapeOf: tree
				  accessorBlock: [ :aTree | 
					  aTree
						  asShapeUMLSequenceDiagram: builder
						  metadata: observedData metadata ]
				  pathSuffix: 'sequence-diagram'.

			  self exportSlotsGraphOf: result ]
]

{ #category : #tests }
MTVisualizationsTest >> testSequenceableCollectionMergeSortCopying [

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
			  | presenter tree builder |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 81;
				  assert: result equals: (1 to: 20) asArray ]
]

{ #category : #tests }
MTVisualizationsTest >> testSequenceableCollectionMergeSortCopyingDetailed [

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
			  | presenter tree builder |
			  tree := observedData tree.

			  builder := self umlSequenceDiagramBuilder:
				             RSUMLSequenceBuilder new.

			  presenter := (MTOverviewSpPresenter on: observedData)
				               umlSequenceDiagramBuilder: builder;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 103;
				  assert: result equals: (1 to: 20) asArray ]
]

{ #category : #tests }
MTVisualizationsTest >> testSequenceableCollectionMergeSortPlugging [

	| tree metadata result handlerExecution handlerBlockPlugging observedData |
	tree := MTContextsTree new.

	handlerExecution := MTHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handlerBlockPlugging := MTHandlerSuspendPlugging new
		                        handler: handlerExecution;
		                        pre: [ (1 to: 20) shuffled sort ];
		                        post: [  ];
		                        yourself.

	result := (MTSession withAllImplementations: { 
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

	observedData := MTObservedDataset new
		                tree: tree;
		                metadata: metadata;
		                yourself.

	"Show here the new presenter."
	(MTOverviewSpPresenter on: observedData)
		umlSequenceDiagramBuilder: RSUMLSequenceBuilder new;
		openWithSpec.

	self
		assert: tree size equals: 81;
		assert: result equals: (1 to: 20) asArray
]

{ #category : #tests }
MTVisualizationsTest >> testSequenceableCollectionMergeSortWithoutCopying [

	| tree result handlerExecution metadata observedData |
	tree := MTContextsTree new.

	handlerExecution := MTHandlerProfiling new
		                    tree: tree;
		                    yourself.

	result := (MTSession withAllImplementations: { 
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

	observedData := MTObservedDataset new
		                tree: tree;
		                metadata: metadata;
		                yourself.

	"Show here the new presenter."
	(MTOverviewSpPresenter on: observedData)
		umlSequenceDiagramBuilder: RSUMLSequenceBuilder new;
		openWithSpec.

	self
		assert: tree size equals: 81;
		assert: result equals: (1 to: 20) asArray
]
