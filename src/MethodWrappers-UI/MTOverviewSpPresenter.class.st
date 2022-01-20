Class {
	#name : #MTOverviewSpPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'sequenceDiagramPresenter',
		'treePresenter',
		'tablePresenter',
		'tree',
		'metadata',
		'tableItems',
		'exportButton',
		'umlSequenceDiagramBuilder'
	],
	#category : #'MethodWrappers-UI'
}

{ #category : #initialization }
MTOverviewSpPresenter >> connectPresenters [

	treePresenter whenTreeShownChangedDo: [ :treeShown | 
		sequenceDiagramPresenter script: [ :aCanvas | 
			| sequenceDiagramShape |
			sequenceDiagramShape := treeShown
				                        asShapeUMLSequenceDiagram:
				                        umlSequenceDiagramBuilder
				                        metadata: metadata.

			aCanvas
				add: sequenceDiagramShape;
				zoomToFit;
				addInteraction: RSCanvasController new ] ].

	exportButton action: [ 
		sequenceDiagramPresenter canvas svgCairoExporter
			zoomToShapesWithPadding: Float goldenPlatinumRatio * 2;
			export ]
]

{ #category : #initialization }
MTOverviewSpPresenter >> initializePresenters [

	| outerLayout innerLayout |
	exportButton := self newButton
		                label: 'Export svg';
		                yourself.

	sequenceDiagramPresenter := self instantiate: SpRoassalPresenter.

	treePresenter := MTSpContextsTreePresenter
		                 owner: self
		                 on: tree -> metadata.

	tablePresenter := self newTable
		                  items: tableItems;
		                  beResizable;
		                  sortingBlock: [ :aDict :anotherDict | 
			                  aDict count > anotherDict count ];
		                  addColumn: (SpStringTableColumn
				                   title: 'CompiledMethod'
				                   evaluated: [ :aDictionary | 
					                   aDictionary compiledMethod displayString ]);
		                  addColumn: (SpStringTableColumn
				                   title: 'Sends count'
				                   evaluated: [ :aDictionary | aDictionary count ]);
		                  "addColumn: (SpStringTableColumn
				                   title: 'Clients'
				                   evaluated: [ :aDictionary | 
					                   aDictionary clients ]);"
		                  addColumn: (SpStringTableColumn
				                   title: 'Receivers'
				                   evaluated: [ :aDictionary | 
					                   aDictionary receivers ]);
		                  addColumn: (SpStringTableColumn
				                   title: 'Cumulated duration'
				                   evaluated: [ :aDictionary | 
					                   aDictionary duration asStringScaledUptoHours ]);
		                  addColumn: (SpStringTableColumn
				                   title: 'Avg duration'
				                   evaluated: [ :aDictionary | 
					                   aDictionary durationAvg
						                   asStringScaledUptoHours ]);
		                  addColumn: (SpStringTableColumn
				                   title: 'StDev duration'
				                   evaluated: [ :aDictionary | 
					                   aDictionary durationStDev
						                   asStringScaledUptoHours ]);
		                  yourself.

	tablePresenter columns do: [ :each | each beSortable ].

	innerLayout := self newPanedLayoutTopToBottom
		               add: treePresenter;
		               add: tablePresenter;
		               positionOfSlider: Float silverRatio;
		               yourself.

	outerLayout := self newPanedLayoutLeftToRight
		               add: innerLayout;
		               add: (self newBoxLayoutTopToBottom
				                add: (self newBoxLayoutLeftToRight
						                 add: exportButton expand: false;
						                 yourself)
				                expand: false;
				                add: sequenceDiagramPresenter expand: true;
				                yourself);
		               positionOfSlider: 1 - Float silverRatio;
		               yourself.

	self layout: outerLayout
]

{ #category : #initialization }
MTOverviewSpPresenter >> initializeWindow: aWindow [

	aWindow
		initialExtent: 1 @ Float silverRatio * 1e3;
		title: (String streamContents: [ :aStream | 
					 | sends eta recvs |
					 sends := 0.
					 recvs := 0.
					 eta := Duration zero.

					 tableItems do: [ :aDictionary | 
							 sends := sends + aDictionary count.
							 recvs := recvs + aDictionary receivers.
							 eta := eta + aDictionary duration ].

					 aStream
						 nextPutAll: tableItems size asString;
						 nextPutAll: ' compiled methods, ';
						 nextPutAll: sends asString;
						 nextPutAll: ' message sends, ';
						 nextPutAll: eta asStringScaledUptoHours;
						 nextPutAll: ' duration.' ])
]

{ #category : #initialization }
MTOverviewSpPresenter >> setModelBeforeInitialization: observedData [

	tree := observedData tree.
	metadata := observedData metadata.
	tableItems := observedData statistics values
]

{ #category : #accessing }
MTOverviewSpPresenter >> umlSequenceDiagramBuilder: aBuilder [

	umlSequenceDiagramBuilder := aBuilder
]
