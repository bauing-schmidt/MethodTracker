Class {
	#name : #MWSpPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'sequenceDiagramPresenter',
		'treePresenter',
		'tablePresenter',
		'tree',
		'metadata',
		'tableItems',
		'exportButton',
		'receiverArgumentsShape',
		'headerShape'
	],
	#category : #'MethodWrappers-UI'
}

{ #category : #initialization }
MWSpPresenter >> connectPresenters [

	treePresenter whenTreeShownChangedDo: [ :treeShown | 
		sequenceDiagramPresenter script: [ :aCanvas | 
			self sequenceDiagramTree: treeShown canvas: aCanvas.
			
			aCanvas
				zoomToFit;
				addInteraction: RSCanvasController new ] ].

	exportButton action: [ 
		sequenceDiagramPresenter canvas svgCairoExporter
			zoomToShapesWithPadding: Float goldenPlatinumRatio * 2;
			export ]
]

{ #category : #'as yet unclassified' }
MWSpPresenter >> headerShape: block [

	headerShape := block
]

{ #category : #initialization }
MWSpPresenter >> initializePresenters [

	| outerLayout innerLayout |
	exportButton := self newButton
		                label: 'Export svg';
		                yourself.

	sequenceDiagramPresenter := self instantiate: SpRoassalPresenter.

	treePresenter := MWSpContextsTreePresenter
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
MWSpPresenter >> initializeWindow: aWindow [

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

{ #category : #'as yet unclassified' }
MWSpPresenter >> receiverArgumentsShape: aBlock [

	receiverArgumentsShape := aBlock
]

{ #category : #'as yet unclassified' }
MWSpPresenter >> sequenceDiagramTree: aTree canvas: aCanvas [

	| builder shapes timedMessageSends objectsSeenSoFar |
	shapes := OrderedCollection new.

	timedMessageSends := OrderedCollection new.
	objectsSeenSoFar := IdentityDictionary new.

	"Preprocessing to create the sequence of message sends."
	aTree
		pre: [ :each | 
			| parent recv client reifiedContext reifiedParentContext timedMessageSend model timespan |
			"Retrive the parent of the `each` context, it is mandatory to have it."
			parent := aTree parent: each ifAbsent: [ Error signal ].

			"Reify the context but ignoring the metadata info because we want to draw
			 the skeleton of the real objects that are involved and not their clones."
			reifiedContext := each asContextReifiedFromWrapping.
			reifiedParentContext := parent asContextReifiedFromWrapping.

			client := reifiedParentContext receiver.
			recv := reifiedContext receiver.

			"Mark both `recv` and `client` as seen in order to stick an alias in the interpolation.
			 The order in which client and recv are inserted matters."
			objectsSeenSoFar
				ifAbsentPutOrderAt: client;
				ifAbsentPutOrderAt: recv.

			"Final addition of this entry."
			model := metadata at: each.

			timespan := TimespanDiscrete new
				            start: model startTime asDateAndTime;
				            duration: model duration;
				            logicalStart: model visit x;
				            logicalDuration: model visitDuration;
				            yourself.

			timedMessageSend := MWTimedMessageSend new
				                    timespan: timespan;
				                    messageSend: ((RSFullMessageSend
						                      receiver: recv
						                      selector: reifiedContext selector
						                      arguments: model reifiedContext arguments)
						                     client: client;
						                     callerSelector:
							                     reifiedParentContext selector;
						                     yourself);
				                    yourself.

			timedMessageSends add: timedMessageSend.

			"Such association is then passed in the `post:` block as second argument."
			timedMessageSend ]
		post: [ :each :timedMessageSend | 
			| timespan returnTimespan returnTimedMessageSend |
			timespan := timedMessageSend timespan.

			returnTimespan := TimespanDiscrete new
				                  start: timespan end;
				                  duration: Duration zero;
				                  logicalStart: timespan logicalStart;
				                  logicalDuration: timespan logicalDuration;
				                  yourself.

			returnTimedMessageSend := MWTimedMessageSend new
				                          timespan: returnTimespan;
				                          messageSend:
					                          (timedMessageSend messageSend
						                           asReturnMessageSend
						                           return: (metadata at: each) return;
						                           yourself);
				                          yourself.

			timedMessageSends add: returnTimedMessageSend ].

	builder := RSUMLSequenceBuilder new
		           objectsSeenSoFar: objectsSeenSoFar;
		           messagesSends: timedMessageSends;
		           previousHeaders: OrderedCollection new;
		           previousMessagesSends: OrderedCollection new;
		           yourself.

	headerShape ifNotNil: [ builder headerShape: headerShape ].

	receiverArgumentsShape ifNotNil: [ 
		builder receiverArgumentsShape: receiverArgumentsShape ].

	builder build.

	shapes add: builder canvas asShape.

	RSVerticalLineLayout new
		verticalGap: -5;
		alignLeft;
		on: shapes.

	^ aCanvas
		  addAll: shapes;
		  yourself
]

{ #category : #initialization }
MWSpPresenter >> setModelBeforeInitialization: observedData [

	tree := observedData tree.
	metadata := observedData metadata.
	tableItems := observedData statistics values
]

{ #category : #'as yet unclassified' }
MWSpPresenter >> useShapeSlotsDfsTree [

	| block slotsVisitor |
	slotsVisitor := MWSlotDescriptorsVisitor new collect: [ :aDescriptor | 
		                aDescriptor
			                headerWithClass;
			                yourself ].

	block := [ :anObject | anObject asShapeSlotsDfsTree: slotsVisitor ].

	self
		headerShape: block;
		receiverArgumentsShape: block
]
