Class {
	#name : #MWSpContextsTreePresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'treePresenter',
		'tree',
		'metadata',
		'recvCheckbox',
		'argsCheckbox',
		'returnCheckbox',
		'expandAllButton',
		'collapseAllButton'
	],
	#category : #'MethodWrappers-UI'
}

{ #category : #initialization }
MWSpContextsTreePresenter >> connectPresenters [

	expandAllButton action: [ treePresenter expandAll ].

	collapseAllButton action: [ treePresenter collapseAll ].

	recvCheckbox whenChangedDo: [ :ann | 
		treePresenter
			display: self treePresenterDisplayBlock;
			refresh ].

	argsCheckbox whenChangedDo: [ :ann | 
		treePresenter
			display: self treePresenterDisplayBlock;
			refresh ].

	returnCheckbox whenChangedDo: [ :ann | 
		treePresenter
			display: self treePresenterDisplayBlock;
			refresh ]
]

{ #category : #initialization }
MWSpContextsTreePresenter >> initializePresenters [

	expandAllButton := self newButton
		                   label: 'Expand all';
		                   yourself.

	collapseAllButton := self newButton
		                     label: 'Collapse all';
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
					  add: recvCheckbox;
					  add: argsCheckbox;
					  add: returnCheckbox;
					  yourself)
			 expand: false;
			 add: treePresenter;
			 yourself)
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
		  recvCheckbox state ifTrue: [ 
			  aStream
				  nextPutAll: reifiedContext receiver asString;
				  nextPut: Character space ].

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
