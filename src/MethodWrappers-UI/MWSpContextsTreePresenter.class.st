Class {
	#name : #MWSpContextsTreePresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'treePresenter',
		'tree',
		'metadata',
		'clientCheckbox',
		'recvCheckbox',
		'argsCheckbox',
		'returnCheckbox',
		'expandAllButton',
		'collapseAllButton',
		'showDetailsButton'
	],
	#category : #'MethodWrappers-UI'
}

{ #category : #initialization }
MWSpContextsTreePresenter >> connectPresenters [

	| treeRefreshDisplayBlock |
	expandAllButton action: [ treePresenter expandAll ].

	collapseAllButton action: [ treePresenter collapseAll ].

	showDetailsButton action: [ self openDetailsWithSpec ].
	
	treeRefreshDisplayBlock := [ :ann | 
	                           treePresenter
		                           display: self treePresenterDisplayBlock;
		                           refresh ].

	clientCheckbox whenChangedDo: treeRefreshDisplayBlock.

	recvCheckbox whenChangedDo: treeRefreshDisplayBlock.

	argsCheckbox whenChangedDo: treeRefreshDisplayBlock.

	returnCheckbox whenChangedDo: treeRefreshDisplayBlock
]

{ #category : #initialization }
MWSpContextsTreePresenter >> initializePresenters [

	expandAllButton := self newButton
		                   label: 'Expand all';
		                   yourself.

	collapseAllButton := self newButton
		                     label: 'Collapse all';
		                     yourself.

	showDetailsButton := self newButton
		                     label: 'Details';
		                     yourself.

	clientCheckbox := self newCheckBox
		                  label: 'Client';
		                  state: false;
		                  yourself.

	recvCheckbox := self newCheckBox
		                label: 'Receiver';
		                state: true;
		                yourself.

	argsCheckbox := self newCheckBox
		                label: 'Arguments';
		                state: false;
		                yourself.

	returnCheckbox := self newCheckBox
		                  label: 'Return';
		                  state: false;
		                  yourself.

	treePresenter := tree asTreePresenter display:
		                 self treePresenterDisplayBlock.

	self layout: (self newBoxLayoutTopToBottom
			 add: (self newBoxLayoutLeftToRight
					  add: expandAllButton;
					  add: collapseAllButton;
					  add: showDetailsButton;
					  add: clientCheckbox;
					  add: recvCheckbox;
					  add: argsCheckbox;
					  add: returnCheckbox;
					  yourself)
			 expand: false;
			 add: treePresenter;
			 yourself)
]

{ #category : #initialization }
MWSpContextsTreePresenter >> openDetailsWithSpec [

	| presenter |
	presenter := CTOrderPreservingTreePresenter on: tree.

	presenter withTreePresenterDo: [ :aPresenter | 
		aPresenter
			addColumn:
				(SpStringTableColumn
					 title: 'Message send'
					 evaluated: [ :aContext | 
						 (metadata at: aContext) reifiedContext
							 asStringInterpolationOfReceiverSelectorArguments ]);
			addColumn: (SpStringTableColumn
					 title: 'Return'
					 evaluated: [ :aContext | (metadata at: aContext) return ]);
			addColumn:
				(SpStringTableColumn title: 'Client' evaluated: [ :aContext | 
						 (metadata at: aContext) client
							 ifNothing: [ '•' ]
							 ifJust: [ :aJust | aJust content ] ]);
			addColumn: (SpStringTableColumn
					 title: 'Send occurrence'
					 evaluated: [ :aContext | (metadata at: aContext) occurrence ]);
			addColumn: (SpStringTableColumn
					 title: 'Send progress'
					 evaluated: [ :aContext | (metadata at: aContext) ratio ]);
			addColumn: (SpStringTableColumn
					 title: 'Entry @ Exit ticks'
					 evaluated: [ :aContext | (metadata at: aContext) visit ]);
			addColumn:
				(SpStringTableColumn title: 'Duration' evaluated: [ :aContext | 
						 (metadata at: aContext) duration asStringScaledUptoHours ]);
			addColumn: (SpStringTableColumn
					 title: 'Start time'
					 evaluated: [ :aContext | (metadata at: aContext) startTime ]);
			expandAll ].

	presenter openWithSpec
]

{ #category : #initialization }
MWSpContextsTreePresenter >> setModelBeforeInitialization: treeMetadataAssociation [

	tree := treeMetadataAssociation key.
	metadata := treeMetadataAssociation value
]

{ #category : #initialization }
MWSpContextsTreePresenter >> treePresenterDisplayBlock [

	^ [ :each | 
	  | reifiedContext |
	  reifiedContext := (metadata at: each) reifiedContext.

	  String streamContents: [ :aStream | 
		  clientCheckbox state ifTrue: [ 
			  (metadata at: each) client
				  ifNothing: [ aStream nextPutAll: '•' ]
				  ifJust: [ :aJust | aStream nextPutAll: aJust content asString ].

			  aStream nextPutAll: ' ◆ ' ].

		  recvCheckbox state
			  ifTrue: [ 
				  aStream
					  nextPutAll: reifiedContext receiver asString;
					  nextPut: Character space ]
			  ifFalse: [ 
				  aStream
					  nextPutAll:
						  (reifiedContext receiver class lookupSelector:
								   reifiedContext selector) methodClassName;
					  nextPutAll: '>>#' ].

		  argsCheckbox state
			  ifTrue: [ 
				  aStream nextPutAll:
					  reifiedContext asStringInterpolationOfSelectorArguments ]
			  ifFalse: [ aStream nextPutAll: reifiedContext selector ].

		  returnCheckbox state ifTrue: [ 
			  aStream
				  nextPutAll: ' → ';
				  nextPutAll: (metadata at: each) return asString ] ] ]
]

{ #category : #initialization }
MWSpContextsTreePresenter >> whenTreeShownChangedDo: aBlock [

	^ treePresenter whenSelectionChangedDo: [ :selectedItem | 
		  | treeShown |
		  treeShown := tree class new.

		  treePresenter allShownItems do: [ :each | 
			  | aParent witness |
			  witness := Object new.

			  aParent := tree parent: each ifAbsent: [ witness ].

			  aParent == witness ifFalse: [ 
				  treeShown parent: aParent child: each ] ].


		  aBlock value: treeShown ]
]
