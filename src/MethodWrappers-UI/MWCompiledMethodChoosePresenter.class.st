Class {
	#name : #MWCompiledMethodChoosePresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'listPresenter',
		'codePresenter',
		'treeTablePresenter',
		'selectedClasses',
		'selectedPackages',
		'selectedMethods'
	],
	#category : #'MethodWrappers-UI'
}

{ #category : #initialization }
MWCompiledMethodChoosePresenter >> initializePresenters [

	| innerLayout outerLayout packages |
	selectedPackages := Set new.
	selectedClasses := Set new.
	selectedMethods := Set new.

	packages := RPackageOrganizer default packages asOrderedCollection 
		            sort: [ :a :b | a name < b name ].

	treeTablePresenter := self newTreeTable
		                      roots: packages;
		                      children: [ :anObject | 
			                      anObject 
				                      childrenForCompiledMethodChoosePresenter:
					                      self ];
		                      lazilyComputeChildren: true;
		                      addColumn: (SpCompositeTableColumn new
				                       title:
					                       'Package → Class → Compiled method ɑ → (senders of ɑ)*';
				                       addColumn:
					                       ((SpCheckBoxTableColumn
						                         title: ' '
						                         evaluated: [ :anObject | 
							                         anObject
								                         belongsPackages: selectedPackages
								                         classes: selectedClasses
								                         methods: selectedMethods ])
						                        onActivation: [ :anObject | 
							                        anObject
								                        activatedPackages: selectedPackages
								                        classes: selectedClasses
								                        methods: selectedMethods ];
						                        onDeactivation: [ :anObject | 
							                        anObject
								                        deactivatedPackages: selectedPackages
								                        classes: selectedClasses
								                        methods: selectedMethods ];
						                        yourself);
				                       addColumn:
					                       (SpImageTableColumn evaluated: [ :each | 
						                        self iconNamed:
							                        (each 
								                         iconNameForCompiledMethodChoosePresenter:
								                         self) ]);
				                       addColumn:
				                       (SpStringTableColumn evaluated: [ :anObject | 
					                        anObject name ]);
				                       yourself);
		                      whenSelectedItemChangedDo: [ :anObject | 
			                      | newCoder |
			                      newCoder := anObject beInCodePresenter: self.
			                      "newCoder
				                      withoutLineNumbers;
				                      beNotEditable."
			                      innerLayout replaceSecond: newCoder.
			                      codePresenter := newCoder ];
		                      yourself.

	listPresenter := self newList.
	codePresenter := self newCode.

	innerLayout := self newPanedLayoutTopToBottom
		               add: treeTablePresenter;
		               add: codePresenter;
		               positionOfSlider: Float silverRatio;
		               yourself.

	outerLayout := self newPanedLayoutLeftToRight
		               add: innerLayout;
		               add: listPresenter;
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
