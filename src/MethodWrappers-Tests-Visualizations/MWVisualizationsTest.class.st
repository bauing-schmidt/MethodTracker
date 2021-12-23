Class {
	#name : #MWVisualizationsTest,
	#superclass : #TestCase,
	#traits : 'TIceImagesExporting',
	#classTraits : 'TIceImagesExporting classTrait',
	#category : #'MethodWrappers-Tests-Visualizations'
}

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
				          (Integer >> #dcMultiplyInteger:base:).
				          (Number >> #add:).
				          (Number >> #subtractNumber:).
				          (Number >> #multiplyNumber:) })
		         do: [ :each | each handler: handlerCopying ];
		         value: [ large := m dcMultiplyInteger: n base: 10 ].

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
				          (Number >> #add:).
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
MWVisualizationsTest >> testProfileSlowFibonacciMemoingWithAdd [

	| handlerCounting handler tree result handlerExecution metadata presenter |
	tree := CTOrderPreservingTree new.

	handlerCounting := MWHandlerCounting new.

	handlerExecution := MWHandlerProfiling new
		                    tree: tree;
		                    yourself.

	handler := MWHandlerMemoing new
		           handler: handlerExecution;
		           yourself.

	result := (MWSession withAllImplementations: { (Number >> #add:) })
		          do: [ :each | each handler: handler ];
		          add: (MWDecorator new
				           compiledMethod: Integer >> #slowFibonacci;
				           handler: handler;
				           yourself);
		          value: [ 6 slowFibonacci ].

	metadata := IdentityDictionary new.
	handlerExecution metadata: metadata.

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
		              compiledMethod: Number >> #add:;
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
		assert: tree size equals: 13;
		assert: result equals: 1356.

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
