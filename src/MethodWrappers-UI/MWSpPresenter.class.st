Class {
	#name : #MWSpPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'sequenceDiagramPresenter',
		'treePresenter',
		'tablePresenter',
		'tree',
		'metadata',
		'methodCountDurationDictionary',
		'tableItems',
		'exportButton',
		'receiverArgumentsShape'
	],
	#category : #'MethodWrappers-UI'
}

{ #category : #initialization }
MWSpPresenter >> connectPresenters [

	treePresenter whenTreeShownChangedDo: [ :treeShown | 
		sequenceDiagramPresenter script: [ :aCanvas | 
			self sequenceDiagramTree: treeShown canvas: aCanvas ] ].

	exportButton action: [ 
		sequenceDiagramPresenter canvas svgCairoExporter
			zoomToShapesWithPadding: Float goldenPlatinumRatio * 2;
			export ]
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
			                  (aDict at: #count) > (anotherDict at: #count) ];
		                  addColumn: (SpStringTableColumn
				                   title: 'CompiledMethod'
				                   evaluated: [ :aDictionary | 
					                   (aDictionary at: #compiledMethod)
						                   displayString ]);
		                  addColumn: (SpStringTableColumn
				                   title: 'Clients'
				                   evaluated: [ :aDictionary | 
					                   aDictionary at: #clients ]);
		                  addColumn: (SpStringTableColumn
				                   title: 'Receivers'
				                   evaluated: [ :aDictionary | 
					                   aDictionary at: #receivers ]);
		                  addColumn: (SpStringTableColumn
				                   title: 'Sends count'
				                   evaluated: [ :aDictionary | 
					                   aDictionary at: #count ]);
		                  addColumn: (SpStringTableColumn
				                   title: 'Cumulated duration'
				                   evaluated: [ :aDictionary | 
					                   (aDictionary at: #duration)
						                   asStringScaledUptoHours ]);
		                  addColumn: (SpStringTableColumn
				                   title: 'Avg duration'
				                   evaluated: [ :aDictionary | 
					                   (aDictionary at: #durationAvg)
						                   asStringScaledUptoHours ]);
		                  addColumn: (SpStringTableColumn
				                   title: 'StDev duration'
				                   evaluated: [ :aDictionary | 
					                   (aDictionary at: #durationStDev)
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
							 sends := sends + (aDictionary at: #count).
							 recvs := recvs + (aDictionary at: #receivers).
							 eta := eta + (aDictionary at: #duration) ].

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
			| parent recv client reifiedContext reifiedParentContext timedMessageSend |
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
			timedMessageSend := MWTimedMessageSend new
				                    timespan: (self timespanOfContext: each);
				                    messageSend: ((RSFullMessageSend
						                      receiver: recv
						                      selector: reifiedContext selector
						                      arguments: reifiedContext arguments)
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
				                  logicalDuration: timespan logicalDuration.

			returnTimedMessageSend := MWTimedMessageSend new
				                          timespan: returnTimespan;
				                          messageSend:
					                          (timedMessageSend messageSend
						                           asReturnMessageSend
						                           return: (metadata at: each) return;
						                           yourself);
				                          yourself.

			timedMessageSends add: returnTimedMessageSend.

			returnTimedMessageSend ].

	builder := RSUMLSequenceBuilder new
		           objectsSeenSoFar: objectsSeenSoFar;
		           messagesSends: timedMessageSends;
		           previousHeaders: OrderedCollection new;
		           previousMessagesSends: OrderedCollection new;
		           yourself.

	receiverArgumentsShape ifNotNil: [ 
		builder receiverArgumentsShape: receiverArgumentsShape ].

	builder build.

	shapes add: builder canvas asShape.

	RSVerticalLineLayout new
		verticalGap: -5;
		alignLeft;
		on: shapes.

	aCanvas
		addAll: shapes;
		zoomToFit;
		addInteraction: RSCanvasController new
]

{ #category : #initialization }
MWSpPresenter >> setModelBeforeInitialization: treeMetadataAssociation [

	tree := treeMetadataAssociation key.
	metadata := treeMetadataAssociation value.

	methodCountDurationDictionary := Dictionary new.
	metadata keysAndValuesDo: [ :each :model | 
		| anArray |
		anArray := methodCountDurationDictionary
			           at: model reifiedContext method
			           ifAbsentPut: [ 
				           { 
					           IdentitySet new.
					           IdentitySet new.
					           0.
					           OrderedCollection new } ].

		(anArray at: 1) add: ((metadata at: each) client
				 ifNothing: [ Object new ]
				 ifJust: [ :aJust | aJust content ]).
		(anArray at: 2) add: each asContextReifiedFromWrapping receiver.
		anArray at: 3 put: (anArray at: 3) + 1.
		(anArray at: 4) add: model duration ].

	tableItems := OrderedCollection new.
	methodCountDurationDictionary keysAndValuesDo: [ :aMethod :anArray | 
		| duration durationAvg durationMinSquaresSum count durationStDev durations |
		count := anArray third.
		durations := anArray fourth.

		duration := durations
			            inject: 0
			            into: [ :nanoSecs :each | 
			            nanoSecs + each asNanoSeconds ].

		durationAvg := duration / count.

		durationMinSquaresSum := durations
			                         inject: 0
			                         into: [ :nanoSecs :each | 
				                         | squaredError |
				                         squaredError := (each asNanoSeconds
				                                          - durationAvg) squared.
				                         nanoSecs + squaredError ].

		durationStDev := count > 1
			                 ifTrue: [ 
			                 (durationMinSquaresSum / (count - 1)) sqrt ]
			                 ifFalse: [ 0 ].

		tableItems add: (Dictionary new
				 at: #compiledMethod put: aMethod;
				 at: #count put: count;
				 at: #duration put: (Duration nanoSeconds: duration);
				 at: #durationAvg put: (Duration nanoSeconds: durationAvg);
				 at: #durationStDev put: (Duration nanoSeconds: durationStDev);
				 at: #clients put: anArray first size;
				 at: #receivers put: anArray second size;
				 yourself) ]
]

{ #category : #'as yet unclassified' }
MWSpPresenter >> timespanOfContext: each [

	| model |
	model := metadata at: each.
	^ TimespanDiscrete new
		  start: model startTime asDateAndTime;
		  duration: model duration;
		  logicalStart: model visit x;
		  logicalDuration: model visitDuration;
		  yourself
]

{ #category : #'as yet unclassified' }
MWSpPresenter >> useShapeSlotsDfsTree [

	self receiverArgumentsShape: [ :anObject | 
		anObject asShapeSlotsDfsTree:
			(anObject slotDescriptorsContext collect: [ :aDescriptor | 
				 aDescriptor
					 headerWithClass;
					 yourself ]) ]
]
