Class {
	#name : #MWVisualizationsTest,
	#superclass : #TestCase,
	#traits : 'TIceImagesExporting + MWTProfilingCopying',
	#classTraits : 'TIceImagesExporting classTrait + MWTProfilingCopying classTrait',
	#category : #'MethodWrappers-Tests-Visualizations'
}

{ #category : #tests }
MWVisualizationsTest >> sutSequenceableCollectionEstrinInit [

	^ { 1. 3. 5. 6. 9 } estrin: 10
]

{ #category : #tests }
MWVisualizationsTest >> sutSequenceableCollectionHornerInit [

	^ { 1. 3. 5. 6 } hornerBase10
]

{ #category : #tests }
MWVisualizationsTest >> testInspectFactorialRecursive [

	| n |
	n := 1 << 4. " 16"

	^ self
		  compiledMethods: { 
				  (Integer >> #factorialRecursive).
				  (Number >> #multiplyNumber:) }
		  wrapping: [ n factorialRecursive ]
		  then: [ :factorial :observedData | 
			  | presenter tree |
			  tree := observedData tree.

			  presenter := (MWSpPresenter on: observedData)
				               useShapeSlotsDfsTree;
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
				  export: tree
				  pathSuffix: 'sequence-diagram'
				  onCanvasDo: [ :aCanvas :useless | 
					  presenter currentCanvas: aCanvas ];
				  exportSlotsGraphOf: factorial ]
]

{ #category : #tests }
MWVisualizationsTest >> testInspectInversions [

	^ self
		  compiledMethods: { 
				  (SequenceableCollection >> #inversions:).
				  (PositionableStream >> #merge:sortBlock:on:inversionsOrNil:).
				  (SequenceableCollection >> #bisect:baseBlock:).
				  (SequenceableCollection >> #bisect:from:to:baseBlock:).
				  (Stream >> #nextPut:inversion:) }
		  wrapping: [ { 2. 4. 1. 3. 5 } inversions: [ :i :j | i < j ] ]
		  then: [ :inversions :observedData | 
			  | presenter tree |
			  tree := observedData tree.

			  presenter := (MWSpPresenter on: observedData)
				               useShapeSlotsDfsTree;
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
				  export: tree
				  pathSuffix: 'sequence-diagram'
				  onCanvasDo: [ :aCanvas :useless | 
					  presenter currentCanvas: aCanvas ];
				  exportSlotsGraphOf: inversions ]
]

{ #category : #tests }
MWVisualizationsTest >> testInspectInversionsReversed [

	^ self
		  compiledMethods: { 
				  (SequenceableCollection >> #inversions:).
				  (PositionableStream >> #merge:sortBlock:on:inversionsOrNil:).
				  (SequenceableCollection >> #bisect:baseBlock:).
				  (SequenceableCollection >> #bisect:from:to:baseBlock:).
				  (Stream >> #nextPut:inversion:) }
		  wrapping: [ { 5. 4. 3. 2. 1 } inversions: [ :i :j | i < j ] ]
		  then: [ :inversions :observedData | 
			  | presenter tree |
			  tree := observedData tree.

			  presenter := (MWSpPresenter on: observedData)
				               useShapeSlotsDfsTree;
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
				  export: tree
				  pathSuffix: 'sequence-diagram'
				  onCanvasDo: [ :aCanvas :useless | 
					  presenter currentCanvas: aCanvas ];
				  exportSlotsGraphOf: inversions ]
]

{ #category : #tests }
MWVisualizationsTest >> testInspectKaratsuba42FactorialSquaredProfiled [

	| m |
	m := 42 factorial.

	^ self
		  compiledMethods: { (Integer >> #karatsuba:base:) }
		  wrapping: [ m karatsuba: m base: 10 ]
		  then: [ :large :observedData | 
			  | presenter tree nBits leaves |
			  tree := observedData tree.

			  presenter := (MWSpPresenter on: observedData)
				               useShapeSlotsDfsTree;
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
MWVisualizationsTest >> testInspectLargeIntegerProfiled [

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
			  | presenter tree |
			  tree := observedData tree.

			  presenter := (MWSpPresenter on: observedData)
				               useShapeSlotsDfsTree;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 41;
				  assert: large equals: m * n.

			  self
				  export: tree
				  pathSuffix: 'sequence-diagram'
				  onCanvasDo: [ :aCanvas :useless | 
					  presenter currentCanvas: aCanvas ];
				  exportSlotsGraphOf: large ]
]

{ #category : #tests }
MWVisualizationsTest >> testInspectLargeIntegerQuickProfiled [

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
			  | presenter tree |
			  tree := observedData tree.

			  presenter := (MWSpPresenter on: observedData)
				               useShapeSlotsDfsTree;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 41;
				  assert: large equals: m * n.

			  self
				  export: tree
				  pathSuffix: 'sequence-diagram'
				  onCanvasDo: [ :aCanvas :useless | 
					  presenter currentCanvas: aCanvas ];
				  exportSlotsGraphOf: large ]
]

{ #category : #tests }
MWVisualizationsTest >> testInspectLargeIntegerSlowProfiled [

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
			  | presenter tree |
			  tree := observedData tree.

			  presenter := (MWSpPresenter on: observedData)
				               useShapeSlotsDfsTree;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 41;
				  assert: large equals: m * n.

			  self
				  export: tree
				  pathSuffix: 'sequence-diagram'
				  onCanvasDo: [ :aCanvas :useless | 
					  presenter currentCanvas: aCanvas ];
				  exportSlotsGraphOf: large ]
]

{ #category : #tests }
MWVisualizationsTest >> testInspectProbabilisticMedian [

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
			  | presenter tree |
			  tree := observedData tree.

			  presenter := (MWSpPresenter on: observedData)
				               useShapeSlotsDfsTree;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 8;
				  assert: median equals: (collection sorted at: (n / 2) floor).

			  self
				  export: tree
				  pathSuffix: 'sequence-diagram'
				  onCanvasDo: [ :aCanvas :useless | 
					  presenter currentCanvas: aCanvas ];
				  exportSlotsGraphOf: median;
				  exportSlotsGraphOf: collection pathSuffix: 'original';
				  exportSlotsGraphOf: collection sorted pathSuffix: 'sorted' ]
]

{ #category : #tests }
MWVisualizationsTest >> testInspectProductTo [

	| n |
	n := 1 << 4.

	^ self
		  compiledMethods: { 
				  (Integer >> #productTo:).
				  (Number >> #addNumber:).
				  (Number >> #multiplyNumber:) }
		  wrapping: [ 1 productTo: n ]
		  then: [ :factorial :observedData | 
			  | presenter tree |
			  tree := observedData tree.

			  presenter := (MWSpPresenter on: observedData)
				               useShapeSlotsDfsTree;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 21;
				  assert: factorial equals: n factorial.

			  self
				  export: tree
				  pathSuffix: 'sequence-diagram'
				  onCanvasDo: [ :aCanvas :useless | 
					  presenter currentCanvas: aCanvas ];
				  exportSlotsGraphOf: factorial ]
]

{ #category : #tests }
MWVisualizationsTest >> testInspectProductToPropagating [

	| n factorial tree handlerExecution handlerCopying metadata presenter handlerPropagating observedData |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handlerCopying := MWHandlerReceiverArgumentsCopying new
		                  handler: handlerExecution;
		                  yourself.

	handlerPropagating := MWHandlerSenderPropagating new
		                      handler: handlerCopying;
		                      yourself.

	n := 1 << 4.

	factorial := (MWSession withAllImplementations:
			              { (Number >> #multiplyNumber:) })
		             do: [ :each | each handler: handlerPropagating ];
		             value: [ 1 productTo: n ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerCopying metadata: metadata.

	observedData := MWObservedData new
		                tree: tree;
		                metadata: metadata;
		                statistics: (self statistics: metadata);
		                yourself.

	presenter := (MWSpPresenter on: observedData)
		             useShapeSlotsDfsTree;
		             openWithSpec;
		             yourself.

	self
		assert: tree size equals: 18;
		assert: factorial equals: n factorial.

	^ self
		  export: tree
		  pathSuffix: 'sequence-diagram'
		  onCanvasDo: [ :aCanvas :useless | 
			  presenter currentCanvas: aCanvas ];
		  exportSlotsGraphOf: factorial
]

{ #category : #tests }
MWVisualizationsTest >> testProfileSlowExplicitFibonacciTailWithAdd [

	^ self
		  compiledMethods: { 
				  (Integer >> #slowExplicitFibonacci:tail:).
				  (Integer >> #slowExplicitFibonacci:tail:greaterThanZeroIsTrue:).
				  (Integer >> #slowExplicitFibonacci:tail:greaterThanZeroIsFalse:).
				  (Number >> #addNumber:) }
		  wrapping: [ 6 slowExplicitFibonacci: 0 tail: 1 ]
		  then: [ :result :observedData | 
			  | presenter tree |
			  tree := observedData tree.

			  presenter := (MWSpPresenter on: observedData)
				               useShapeSlotsDfsTree;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 20;
				  assert: result equals: 6 fibonacciNumbers last.

			  self
				  export: tree
				  pathSuffix: 'sequence-diagram'
				  onCanvasDo: [ :aCanvas :useless | 
				  presenter currentCanvas: aCanvas ] ]
]

{ #category : #tests }
MWVisualizationsTest >> testProfileSlowFibonacciMemoingWithAdd [

	^ self
		  compiledMethods: { 
				  (Integer >> #slowFibonacciMemo:).
				  (Number >> #addNumber:) }
		  wrapping: [ 6 slowFibonacciMemo: Dictionary new ]
		  then: [ :result :observedData | 
			  | presenter tree |
			  tree := observedData tree.

			  presenter := (MWSpPresenter on: observedData)
				               useShapeSlotsDfsTree;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 16;
				  assert: result equals: 7 fibonacciNumbers last.

			  self
				  export: tree
				  pathSuffix: 'sequence-diagram'
				  onCanvasDo: [ :aCanvas :useless | 
				  presenter currentCanvas: aCanvas ] ]
]

{ #category : #tests }
MWVisualizationsTest >> testProfileSlowFibonacciTailWithAdd [

	^ self
		  compiledMethods: { 
				  (Integer >> #slowFibonacci:tail:).
				  (Number >> #addNumber:) }
		  wrapping: [ 6 slowFibonacci: 0 tail: 1 ]
		  then: [ :result :observedData | 
			  | presenter tree |
			  tree := observedData tree.

			  presenter := (MWSpPresenter on: observedData)
				               useShapeSlotsDfsTree;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 13;
				  assert: result equals: 6 fibonacciNumbers last.

			  self
				  export: tree
				  pathSuffix: 'sequence-diagram'
				  onCanvasDo: [ :aCanvas :useless | 
				  presenter currentCanvas: aCanvas ] ]
]

{ #category : #tests }
MWVisualizationsTest >> testProfileSlowFibonacciWithAdd [

	^ self
		  compiledMethods: { 
				  (Integer >> #slowFibonacci).
				  (Number >> #addNumber:) }
		  wrapping: [ 6 slowFibonacci ]
		  then: [ :result :observedData | 
			  | presenter tree |
			  tree := observedData tree.

			  presenter := (MWSpPresenter on: observedData)
				               useShapeSlotsDfsTree;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 37;
				  assert: result equals: 7 fibonacciNumbers last. " 55"

			  self
				  export: tree
				  pathSuffix: 'sequence-diagram'
				  onCanvasDo: [ :aCanvas :useless | 
				  presenter currentCanvas: aCanvas ] ]
]

{ #category : #tests }
MWVisualizationsTest >> testProfileSlowFibonacciWithAddOnly [

	^ self
		  compiledMethods: { (Number >> #addNumber:) }
		  wrapping: [ 6 slowFibonacci ]
		  then: [ :result :observedData | 
			  | presenter tree |
			  tree := observedData tree.

			  presenter := (MWSpPresenter on: observedData)
				               useShapeSlotsDfsTree;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 12;
				  assert: result equals: 7 fibonacciNumbers last. " 55"

			  self
				  export: tree
				  pathSuffix: 'sequence-diagram'
				  onCanvasDo: [ :aCanvas :useless | 
				  presenter currentCanvas: aCanvas ] ]
]

{ #category : #tests }
MWVisualizationsTest >> testSequenceableCollectionEstrinInit [

	^ self
		  compiledMethods: { 
				  (SequenceableCollection >> #estrin:init:).
				  (Number >> #addNumber:).
				  (Number >> #multiplyNumber:) }
		  wrapping: [ self sutSequenceableCollectionEstrinInit ]
		  then: [ :result :observedData | 
			  | presenter tree |
			  tree := observedData tree.

			  presenter := (MWSpPresenter on: observedData)
				               useShapeSlotsDfsTree;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 17;
				  assert: result equals: 13569.

			  self
				  export: tree
				  pathSuffix: 'sequence-diagram'
				  onCanvasDo: [ :aCanvas :useless | 
					  presenter currentCanvas: aCanvas ];
				  exportSlotsGraphOf: result ]
]

{ #category : #tests }
MWVisualizationsTest >> testSequenceableCollectionHornerInit [

	^ self
		  compiledMethods: { 
				  (SequenceableCollection >> #horner:init:).
				  (Number >> #addNumber:).
				  (Number >> #multiplyNumber:) }
		  wrapping: [ self sutSequenceableCollectionHornerInit ]
		  then: [ :result :observedData | 
			  | presenter tree |
			  tree := observedData tree.

			  presenter := (MWSpPresenter on: observedData)
				               useShapeSlotsDfsTree;
				               openWithSpec;
				               yourself.

			  self
				  assert: tree size equals: 9;
				  assert: result equals: 1356.

			  self
				  export: tree
				  pathSuffix: 'sequence-diagram'
				  onCanvasDo: [ :aCanvas :useless | 
					  presenter currentCanvas: aCanvas ];
				  exportSlotsGraphOf: result ]
]
