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
MWSpPresenter >> initializePresenters [

	| outerLayout innerLayout |
	sequenceDiagramPresenter := self instantiate: SpRoassalPresenter.

	treePresenter := tree asTreePresenter display: [ :each | 
		                 (metadata at: each) reifiedContext
			                 asStringInterpolationOfReceiverSelectorArguments ].

	treePresenter whenSelectionChangedDo: [ :selectedItem | 
		sequenceDiagramPresenter script: [ :aCanvas | 
			| treeShown |
			treeShown := tree class new.

			treePresenter allShownItems do: [ :each | 
				| aParent witness |
				witness := Object new.

				aParent := tree parent: each ifAbsent: [ witness ].

				aParent == witness ifFalse: [ 
					treeShown parent: aParent child: each ] ].


			self sequenceDiagramTree: treeShown canvas: aCanvas ] ] yourself.

	tablePresenter := self newTable
		                  items: tableItems;
		                  beResizable;
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
		                  yourself.

	tablePresenter columns do: [ :each | each beSortable ].

	innerLayout := self newPanedLayoutTopToBottom
		               add: treePresenter;
		               add: tablePresenter;
		               yourself.



	outerLayout := self newPanedLayoutLeftToRight
		               add: innerLayout;
		               add: sequenceDiagramPresenter;
		               yourself.

	self layout: outerLayout
]

{ #category : #'as yet unclassified' }
MWSpPresenter >> sequenceDiagramTree: aTree canvas: aCanvas [

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

	aCanvas
		addAll: shapes;
		zoomToFit;
		"in: [ :c | 
			c svgExporter
				zoomToShapes;
				export ];"
		addInteraction: RSCanvasController new
]

{ #category : #initialization }
MWSpPresenter >> setModelBeforeInitialization: treeMetadataAssociation [

	tree := treeMetadataAssociation key.
	metadata := treeMetadataAssociation value.

	methodCountDurationDictionary := Dictionary new.
	metadata valuesDo: [ :model | 
		| anAssoc |
		anAssoc := methodCountDurationDictionary
			           at: model reifiedContext method
			           ifAbsentPut: [ 0 -> Duration zero ].
		anAssoc key: anAssoc key + 1.
		anAssoc value: anAssoc value + model duration ].

	tableItems := OrderedCollection new.
	methodCountDurationDictionary keysAndValuesDo: [ :aMethod :anAssoc | 
		tableItems add: (Dictionary new
				 at: #compiledMethod put: aMethod;
				 at: #count put: anAssoc key;
				 at: #duration put: anAssoc value;
				 yourself) ]
]
