Class {
	#name : #MWCompiledMethodChoosePresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'listPresenter',
		'codePresenter',
		'treeTablePresenter',
		'selectedClasses',
		'selectedPackages'
	],
	#category : #'MethodWrappers-UI'
}

{ #category : #initialization }
MWCompiledMethodChoosePresenter >> initializePresenters [

	| innerLayout outerLayout packages |
	selectedClasses := Set new.
	selectedPackages := Set new.

	packages := RPackageOrganizer default packages asOrderedCollection 
		            sort: [ :a :b | a name < b name ].

	treeTablePresenter := self newTreeTable
		                      roots: packages;
		                      children: [ :anObject | 
			                      anObject 
				                      childrenForCompiledMethodChoosePresenter:
					                      self ];
		                      lazilyComputeChildren: true;
		                      addColumn:
			                      (SpCheckBoxTableColumn
				                       title: ' '
				                       evaluated: [ :anObject | true ]);
		                      addColumn: (SpStringTableColumn
				                       title: ' '
				                       evaluated: [ :anObject | anObject name ]);
		                      yourself.

	listPresenter := self newList.
	codePresenter := self newCode.

	innerLayout := self newPanedLayoutTopToBottom
		               add: listPresenter;
		               add: codePresenter;
		               positionOfSlider: Float silverRatio;
		               yourself.

	outerLayout := self newPanedLayoutLeftToRight
		               add: innerLayout;
		               add: treeTablePresenter;
		               positionOfSlider: 1 - Float silverRatio;
		               yourself.

	self layout: outerLayout
]

{ #category : #initialization }
MWCompiledMethodChoosePresenter >> initializeWindow: aWindow [

	aWindow
		initialExtent: 1 @ Float silverRatio * 1e3;
		title: 'Choose'
]
