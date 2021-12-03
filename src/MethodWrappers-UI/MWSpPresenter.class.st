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
		'tableItems'
	],
	#category : #'MethodWrappers-UI'
}

{ #category : #initialization }
MWSpPresenter >> connectPresenters [

	treePresenter whenTreeShownChangedDo: [ :treeShown | 
		sequenceDiagramPresenter script: [ :aCanvas | 
			self sequenceDiagramTree: treeShown canvas: aCanvas ] ]
]

{ #category : #initialization }
MWSpPresenter >> initializePresenters [

	| outerLayout innerLayout |
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
		                  addColumn: (SpStringTableColumn
				                   title: 'Receivers'
				                   evaluated: [ :aDictionary | 
					                   aDictionary at: #receivers ]);
		                  yourself.

	tablePresenter columns do: [ :each | each beSortable ].

	innerLayout := self newPanedLayoutTopToBottom
		               add: treePresenter;
		               add: tablePresenter;
		               positionOfSlider: Float silverRatio;
		               yourself.

	outerLayout := self newPanedLayoutLeftToRight
		               add: innerLayout;
		               add: sequenceDiagramPresenter;
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
MWSpPresenter >> sequenceDiagramTree: aTree canvas: aCanvas [

	| builder shapes orderedCalls objectsSeenSoFar levels |
	shapes := OrderedCollection new.

	orderedCalls := OrderedCollection new.
	objectsSeenSoFar := IdentityDictionary new.
	levels := IdentityDictionary new.

	aTree
		pre: [ :each :level | 
			| messageSend ctx span model ctxParent parent recv client |
			parent := aTree parent: each ifAbsent: [ Error signal ].
			model := metadata at: each.
			ctx := model reifiedContext.
			ctxParent := (metadata at: parent) reifiedContext.

			client := parent asContextReifiedFromWrapping receiver.
			recv := each asContextReifiedFromWrapping receiver.

			{ 
				client.
				recv } do: [ :anObject | 
				objectsSeenSoFar
					at: anObject
					ifAbsentPut: [ objectsSeenSoFar size + 1 ] ].

			messageSend := (RSFullMessageSend
				                receiver: recv
				                selector: ctx selector
				                arguments:
					                each asContextReifiedFromWrapping arguments)
				               client: client;
				               callerSelector: ctxParent selector;
				               yourself.

			span := TimespanDiscrete new
				        start: model startTime asDateAndTime;
				        duration: model duration;
				        logicalStart: model visit x;
				        logicalDuration: model visitDuration;
				        yourself.

			span -> messageSend yourself: [ :anAssoc | 
				orderedCalls add: anAssoc.
				levels at: anAssoc put: level ] ]
		post: [ :each :anAssoc :level | 
			anAssoc value in: [ :fullMessageSend | 
				| returnMessageSend return timespan returnTimespan returnAssoc |
				return := (metadata at: each) return.

				returnMessageSend := fullMessageSend asReturnMessageSend
					                     return: return;
					                     yourself.

				timespan := anAssoc key.

				returnTimespan := TimespanDiscrete new
					                  start: timespan end;
					                  duration: Duration zero;
					                  logicalStart: timespan logicalStart;
					                  logicalDuration: timespan logicalDuration.

				returnAssoc := returnTimespan -> returnMessageSend.

				orderedCalls add: returnAssoc.
				levels at: returnAssoc put: level ] ].

	builder := RSUMLSequenceBuilder new
		           objectsSeenSoFar: objectsSeenSoFar;
		           levels: levels;
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

	aCanvas
		addAll: shapes;
		zoomToFit;
		"in: [ :c | 
			RSSVGCairoExporter new
				canvas: aCanvas;
				zoomToShapesWithPadding: Float goldenPlatinumRatio;
				export ];"
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
					           0.
					           OrderedCollection new } ].

		(anArray at: 1) add: each asContextReifiedFromWrapping receiver.
		anArray at: 2 put: (anArray at: 2) + 1.
		(anArray at: 3) add: model duration ].

	tableItems := OrderedCollection new.
	methodCountDurationDictionary keysAndValuesDo: [ :aMethod :anArray | 
		| duration durationAvg durationMinSquaresSum count durationStDev |
		count := anArray second.

		duration := anArray third
			            inject: 0
			            into: [ :nanoSecs :each | 
			            nanoSecs + each asNanoSeconds ].

		durationAvg := duration / count.

		durationMinSquaresSum := anArray third
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
				 at: #receivers put: anArray first size;
				 yourself) ]
]
