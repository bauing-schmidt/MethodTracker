Class {
	#name : #MWVisualizationsTest,
	#superclass : #TestCase,
	#traits : 'TIceImagesExporting',
	#classTraits : 'TIceImagesExporting classTrait',
	#category : #'MethodWrappers-Tests-Visualizations'
}

{ #category : #tests }
MWVisualizationsTest >> testInspectFactorialRecursive [

	| n factorial tree handlerExecution handlerCopying metadata presenter |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handlerCopying := MWHandlerReceiverArgumentsCopying new
		                  handler: handlerExecution;
		                  yourself.

	n := 1 << 4.

	factorial := (MWSession withAllImplementations: { 
				              (Integer >> #factorialRecursive).
				              "(Number >> #subtractNumber:)."
				              (Number >> #multiplyNumber:) })
		             do: [ :each | each handler: handlerCopying ];
		             value: [ n factorialRecursive ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerCopying metadata: metadata.

	"Show here the new presenter."
	presenter := (MWSpPresenter on: tree -> metadata)
		             useShapeSlotsDfsTree;
		             openWithSpec;
		             yourself.
	"		useShapeSlotsDfsTree;"

	self
		assert: tree size equals: 33;
		assert: factorial equals: 20922789888000;
		assert: factorial equals: n factorial.

	^ self
		  export: tree
		  pathSuffix: 'sequence-diagram'
		  onCanvasDo: [ :aCanvas :useless | 
			  presenter currentCanvas: aCanvas ];
		  exportSlotsGraphOf: factorial
	"exportShapeOf: tree
		  accessorBlock: [ :aTree | 
			  aTree asShapeValuesHorizontalTreeWithLabelShapes ]
		  pathSuffix: 'contexts-tree';"
]

{ #category : #tests }
MWVisualizationsTest >> testInspectInversions [

	|  inversions tree handlerExecution handlerCopying metadata presenter |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handlerCopying := MWHandlerReceiverArgumentsCopying new
		                  handler: handlerExecution;
		                  yourself.

	inversions := (MWSession withAllImplementations: { 
				               (SequenceableCollection >> #inversions:).
				               (PositionableStream
				                >> #merge:sortBlock:on:inversionsOrNil:).
				               (SequenceableCollection >> #bisect:baseBlock:).
				               (SequenceableCollection
				                >> #bisect:from:to:baseBlock:).
				               (Stream >> #nextPut:inversion:) })
		              do: [ :each | each handler: handlerCopying ];
		              value: [ 
			              { 2. 4. 1. 3. 5 } inversions: [ :i :j | i < j ] ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerCopying metadata: metadata.

	"Show here the new presenter."
	presenter := (MWSpPresenter on: tree -> metadata)
		             useShapeSlotsDfsTree;
		             openWithSpec;
		             yourself.

	self
		assert: tree size equals: 18;
		assert: inversions equals: { 
				(1 -> 2).
				(1 -> 4).
				(3 -> 4) }

	"^ self
		  export: tree
		  pathSuffix: 'sequence-diagram'
		  onCanvasDo: [ :aCanvas :useless | 
			  presenter currentCanvas: aCanvas ];
		  exportSlotsGraphOf: inversions"
]

{ #category : #tests }
MWVisualizationsTest >> testInspectInversionsReversed [

	| inversions tree handlerExecution handlerCopying metadata presenter |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handlerCopying := MWHandlerReceiverArgumentsCopying new
		                  handler: handlerExecution;
		                  yourself.


	inversions := (MWSession withAllImplementations: { 
				               (SequenceableCollection >> #inversions:).
				               (PositionableStream
				                >> #merge:sortBlock:on:inversionsOrNil:).
				               (SequenceableCollection >> #bisect:baseBlock:).
				               (SequenceableCollection
				                >> #bisect:from:to:baseBlock:).
				               (Stream >> #nextPut:inversion:) })
		              do: [ :each | each handler: handlerCopying ];
		              value: [ 
			              { 5. 4. 3. 2. 1 } inversions: [ :i :j | i < j ] ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerCopying metadata: metadata.

	"Show here the new presenter."
	presenter := (MWSpPresenter on: tree -> metadata)
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
				(2 -> 5) }

	"^ self
		  export: tree
		  pathSuffix: 'sequence-diagram'
		  onCanvasDo: [ :aCanvas :useless | 
			  presenter currentCanvas: aCanvas ];
		  exportSlotsGraphOf: inversions"
]

{ #category : #tests }
MWVisualizationsTest >> testInspectKaratsuba42FactorialSquaredProfiled [

	| m large tree handlerExecution handlerCopying metadata presenter nBits leaves |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handlerCopying := MWHandlerReceiverArgumentsCopying new
		                  handler: handlerExecution;
		                  yourself.

	m := 42 factorial.

	large := (MWSession withAllImplementations:
			          { (Integer >> #karatsuba:base:) })
		         do: [ :each | each handler: handlerCopying ];
		         value: [ large := m karatsuba: m base: 10 ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerCopying metadata: metadata.

	"Show here the new presenter."
	presenter := (MWSpPresenter on: tree -> metadata)
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
		assert: large equals: m * m

	"^ self
		  export: tree
		  pathSuffix: 'sequence-diagram'
		  onCanvasDo: [ :aCanvas :useless | 
			  presenter currentCanvas: aCanvas ];
		  exportSlotsGraphOf: large"
	"exportShapeOf: tree
		  accessorBlock: [ :aTree | 
			  aTree asShapeValuesHorizontalTreeWithLabelShapes ]
		  pathSuffix: 'contexts-tree';"
]

{ #category : #tests }
MWVisualizationsTest >> testInspectLargeIntegerProfiled [

	| m n large tree handlerExecution handlerCopying metadata presenter |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handlerCopying := MWHandlerReceiverArgumentsCopying new
		                  handler: handlerExecution;
		                  yourself.

	m := 835.
	n := 714.

	large := (MWSession withAllImplementations: { 
				          (Integer >> #karatsuba:base:).
				          (Number >> #addNumber:).
				          (Number >> #subtractNumber:).
				          (Number >> #multiplyNumber:) })
		         do: [ :each | each handler: handlerCopying ];
		         value: [ large := m karatsuba: n base: 10 ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerCopying metadata: metadata.

	"Show here the new presenter."
	presenter := (MWSpPresenter on: tree -> metadata)
		             useShapeSlotsDfsTree;
		             openWithSpec;
		             yourself.

	self
		assert: tree size equals: 41;
		assert: large equals: m * n.

	^ self
		  export: tree
		  pathSuffix: 'sequence-diagram'
		  onCanvasDo: [ :aCanvas :useless | 
			  presenter currentCanvas: aCanvas ];
		  exportSlotsGraphOf: large
	"exportShapeOf: tree
		  accessorBlock: [ :aTree | 
			  aTree asShapeValuesHorizontalTreeWithLabelShapes ]
		  pathSuffix: 'contexts-tree';"
]

{ #category : #tests }
MWVisualizationsTest >> testInspectLargeIntegerQuickProfiled [

	| m n large tree handlerExecution handlerCopying metadata presenter |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handlerCopying := MWHandlerReceiverArgumentsCopying new
		                  handler: handlerExecution;
		                  yourself.

	m := 835.
	n := 714.

	large := (MWSession withAllImplementations: { 
				          (Integer >> #dcMultiplyIntegerQuick:base:).
				          (Integer >> #bitAdd:).
				          (Number >> #subtractNumber:).
				          (Number >> #multiplyNumber:) })
		         do: [ :each | each handler: handlerCopying ];
		         value: [ large := m dcMultiplyIntegerQuick: n base: 10 ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerCopying metadata: metadata.

	"Show here the new presenter."
	presenter := (MWSpPresenter on: tree -> metadata)
		             openWithSpec;
		             yourself.
	"		useShapeSlotsDfsTree;"

	self
		assert: tree size equals: 41;
		assert: large equals: m * n.

	^ self
		  export: tree
		  pathSuffix: 'sequence-diagram'
		  onCanvasDo: [ :aCanvas :useless | 
			  presenter currentCanvas: aCanvas ];
		  exportSlotsGraphOf: large
	"exportShapeOf: tree
		  accessorBlock: [ :aTree | 
			  aTree asShapeValuesHorizontalTreeWithLabelShapes ]
		  pathSuffix: 'contexts-tree';"
]

{ #category : #tests }
MWVisualizationsTest >> testInspectLargeIntegerSlowProfiled [

	| m n large tree handlerExecution handlerCopying metadata presenter |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handlerCopying := MWHandlerReceiverArgumentsCopying new
		                  handler: handlerExecution;
		                  yourself.

	m := 835.
	n := 714.

	large := (MWSession withAllImplementations: { 
				          (Integer >> #dcMultiplyIntegerSlow:base:).
				          (Number >> #addNumber:).
				          (Number >> #subtractNumber:).
				          (Number >> #multiplyNumber:) })
		         do: [ :each | each handler: handlerCopying ];
		         value: [ large := m dcMultiplyIntegerSlow: n base: 10 ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerCopying metadata: metadata.

	"Show here the new presenter."
	presenter := (MWSpPresenter on: tree -> metadata)
		             openWithSpec;
		             yourself.
	"		useShapeSlotsDfsTree;"

	self
		assert: tree size equals: 41;
		assert: large equals: m * n.

	^ self
		  export: tree
		  pathSuffix: 'sequence-diagram'
		  onCanvasDo: [ :aCanvas :useless | 
			  presenter currentCanvas: aCanvas ];
		  exportSlotsGraphOf: large
	"exportShapeOf: tree
		  accessorBlock: [ :aTree | 
			  aTree asShapeValuesHorizontalTreeWithLabelShapes ]
		  pathSuffix: 'contexts-tree';"
]

{ #category : #tests }
MWVisualizationsTest >> testInspectProductTo [

	| n factorial tree handlerExecution handlerCopying metadata presenter |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handlerCopying := MWHandlerReceiverArgumentsCopying new
		                  handler: handlerExecution;
		                  yourself.

	n := 1 << 4.

	factorial := (MWSession withAllImplementations: { 
				              (Integer >> #productTo:).
				              (Number >> #addNumber:).
				              "(Number >> #subtractNumber:)."
				              (Number >> #multiplyNumber:) })
		             do: [ :each | each handler: handlerCopying ];
		             value: [ 1 productTo: n ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerCopying metadata: metadata.

	"Show here the new presenter."
	presenter := (MWSpPresenter on: tree -> metadata)
		             useShapeSlotsDfsTree;
		             openWithSpec;
		             yourself.

	self
		assert: tree size equals: 21;
		assert: factorial equals: n factorial.

	^ self
		  export: tree
		  pathSuffix: 'sequence-diagram'
		  onCanvasDo: [ :aCanvas :useless | 
			  presenter currentCanvas: aCanvas ];
		  exportSlotsGraphOf: factorial
	"exportShapeOf: tree
		  accessorBlock: [ :aTree | 
			  aTree asShapeValuesHorizontalTreeWithLabelShapes ]
		  pathSuffix: 'contexts-tree';"
]

{ #category : #tests }
MWVisualizationsTest >> testInspectProductToPropagating [

	| n factorial tree handlerExecution handlerCopying metadata presenter handlerPropagating |
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
	"(Integer >> #productTo:)."

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerCopying metadata: metadata.

	"Show here the new presenter."
	presenter := (MWSpPresenter on: tree -> metadata)
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
	"exportShapeOf: tree
		  accessorBlock: [ :aTree | 
			  aTree asShapeValuesHorizontalTreeWithLabelShapes ]
		  pathSuffix: 'contexts-tree';"
]

{ #category : #tests }
MWVisualizationsTest >> testProfileSlowFibonacciMemoingWithAdd [

	| tree result handlerExecution metadata presenter handlerCopying |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handlerCopying := MWHandlerReceiverArgumentsCopying new
		                  handler: handlerExecution;
		                  yourself.

	result := MWSession new
		          add: (MWDecorator new
				           compiledMethod: Integer >> #slowFibonacciMemo:;
				           handler: handlerCopying;
				           yourself);
		          add: (MWDecorator new
				           compiledMethod: Number >> #addNumber:;
				           handler: handlerExecution;
				           yourself);
		          value: [ 6 slowFibonacciMemo: Dictionary new ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerCopying metadata: metadata.

	"Show here the new presenter."
	presenter := (MWSpPresenter on: tree -> metadata)
		             useShapeSlotsDfsTree;
		             openWithSpec;
		             yourself.

	self
		assert: tree size equals: 16;
		assert: result equals: 7 fibonacciNumbers last.

	self
		export: tree
		pathSuffix: 'sequence-diagram'
		onCanvasDo: [ :aCanvas :useless | presenter currentCanvas: aCanvas ]
]

{ #category : #tests }
MWVisualizationsTest >> testProfileSlowFibonacciTailWithAdd [

	| wrapper handlerExecution tree metadata result wrapperAdd presenter |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	wrapper := MWDecorator new
		           compiledMethod: Integer >> #slowFibonacci:tail:;
		           handler: handlerExecution;
		           yourself.

	wrapperAdd := MWDecorator new
		              compiledMethod: Number >> #addNumber:;
		              handler: handlerExecution;
		              yourself.

	result := MWSession new
		          add: wrapper;
		          add: wrapperAdd;
		          value: [ 6 slowFibonacci: 0 tail: 1 ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.

	"Show here the new presenter."
	presenter := (MWSpPresenter on: tree -> metadata)
		             useShapeSlotsDfsTree;
		             openWithSpec;
		             yourself.

	self
		assert: tree size equals: 13;
		assert: result equals: 7 fibonacciNumbers last.

	self
		export: tree
		pathSuffix: 'sequence-diagram'
		onCanvasDo: [ :aCanvas :useless | presenter currentCanvas: aCanvas ]
]

{ #category : #tests }
MWVisualizationsTest >> testProfileSlowFibonacciWithAdd [

	| wrapper handlerExecution tree metadata result wrapperAdd presenter |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	wrapper := MWDecorator new
		           compiledMethod: Integer >> #slowFibonacci;
		           handler: handlerExecution;
		           yourself.

	wrapperAdd := MWDecorator new
		              compiledMethod: Number >> #addNumber:;
		              handler: handlerExecution;
		              yourself.

	result := MWSession new
		          add: wrapper;
		          add: wrapperAdd;
		          value: [ 6 slowFibonacci ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.

	"Show here the new presenter."
	presenter := (MWSpPresenter on: tree -> metadata)
		             useShapeSlotsDfsTree;
		             openWithSpec;
		             yourself.

	self
		assert: tree size equals: 37;
		assert: result equals: 7 fibonacciNumbers last. " 55"

	self
		export: tree
		pathSuffix: 'sequence-diagram'
		onCanvasDo: [ :aCanvas :useless | presenter currentCanvas: aCanvas ]
]

{ #category : #tests }
MWVisualizationsTest >> testProfileSlowFibonacciWithAddOnly [

	| handlerExecution tree metadata result wrapperAdd presenter |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	wrapperAdd := MWDecorator new
		              compiledMethod: Number >> #addNumber:;
		              handler: handlerExecution;
		              yourself.

	result := MWSession new
		          add: wrapperAdd;
		          value: [ 6 slowFibonacci ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.

	"Show here the new presenter."
	presenter := (MWSpPresenter on: tree -> metadata)
		             useShapeSlotsDfsTree;
		             openWithSpec;
		             yourself.

	self
		assert: tree size equals: 12;
		assert: result equals: 7 fibonacciNumbers last. " 55"

	self
		export: tree
		pathSuffix: 'sequence-diagram'
		onCanvasDo: [ :aCanvas :useless | presenter currentCanvas: aCanvas ]
]

{ #category : #tests }
MWVisualizationsTest >> testSequenceableCollectionEstrinInit [

	| tree metadata result handlerExecution handlerCopying presenter |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handlerCopying := MWHandlerReceiverArgumentsCopying new
		                  handler: handlerExecution;
		                  yourself.

	result := (MWSession withAllImplementations: { 
				           (SequenceableCollection >> #estrin:init:).
				           "(Collection >> #inject:into:)."
				           (Number >> #addNumber:).
				           (Number >> #multiplyNumber:) })
		          do: [ :each | each handler: handlerCopying ];
		          value: [ { 1. 3. 5. 6. 9 } estrin: 10 ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerCopying metadata: metadata.

	"Show here the new presenter."
	presenter := (MWSpPresenter on: tree -> metadata)
		             useShapeSlotsDfsTree;
		             openWithSpec;
		             yourself.

	self
		assert: tree size equals: 17;
		assert: result equals: 13569.

	self
		export: tree
		pathSuffix: 'sequence-diagram'
		onCanvasDo: [ :aCanvas :useless | presenter currentCanvas: aCanvas ];
		exportSlotsGraphOf: result
]

{ #category : #tests }
MWVisualizationsTest >> testSequenceableCollectionHornerInit [

	| tree metadata result handlerExecution handlerCopying presenter |
	tree := CTOrderPreservingTree new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handlerCopying := MWHandlerReceiverArgumentsCopying new
		                  handler: handlerExecution;
		                  yourself.

	result := (MWSession withAllImplementations: { 
				           (SequenceableCollection >> #horner:init:).
				           "(Collection >> #inject:into:)."
				           (Number >> #addNumber:).
				           (Number >> #multiplyNumber:) })
		          do: [ :each | each handler: handlerCopying ];
		          value: [ { 1. 3. 5. 6 } hornerBase10 ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.
	handlerCopying metadata: metadata.

	"Show here the new presenter."
	presenter := (MWSpPresenter on: tree -> metadata)
		             useShapeSlotsDfsTree;
		             openWithSpec;
		             yourself.

	self
		assert: tree size equals: 9;
		assert: result equals: 1356.

	self
		export: tree
		pathSuffix: 'sequence-diagram'
		onCanvasDo: [ :aCanvas :useless | presenter currentCanvas: aCanvas ];
		exportSlotsGraphOf: result
]
