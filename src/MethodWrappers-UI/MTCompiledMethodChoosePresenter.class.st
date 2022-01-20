Class {
	#name : #MTCompiledMethodChoosePresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'listPresenter',
		'codePresenter',
		'treeTablePresenter',
		'selectedClasses',
		'selectedPackages',
		'selectedMethods',
		'selectorPresenter',
		'recipientListPresenter'
	],
	#category : #'MethodWrappers-UI'
}

{ #category : #initialization }
MTCompiledMethodChoosePresenter >> initializePresenters [

	| innerLayout outerLayout packages compiledMethodSortingBlock |
	selectedPackages := Set new.
	selectedClasses := Set new.
	selectedMethods := Set new.

	compiledMethodSortingBlock := [ :aMethod :anotherMethod | 
	                              aMethod selector
	                              = anotherMethod selector
		                              ifTrue: [ 
		                              aMethod methodClassName
		                              < anotherMethod methodClassName ]
		                              ifFalse: [ 
		                              aMethod selector
		                              < anotherMethod selector ] ].

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
								                        methods: selectedMethods.

							                        listPresenter items:
									                        (selectedMethods asSortedCollection:
											                         compiledMethodSortingBlock) ];
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
			                      anObject isCompiledMethod ifTrue: [ 
				                      | newCoder |
				                      newCoder := SpCodePresenter new
					                                  text: anObject formattedCode;
					                                  beForMethod: anObject;
					                                  withoutLineNumbers;
					                                  beNotEditable;
					                                  yourself.

				                      innerLayout replaceFirst: newCoder.
				                      codePresenter := newCoder.

				                      recipientListPresenter items:
					                      (anObject sendNodes flatCollect: [ :aRBNode | 
						                       aRBNode selector asSymbol implementors ])
						                      asSet ] ];
		                      yourself.

	listPresenter := self newFilteringList
		                 display: [ :aCompiledMethod | aCompiledMethod name ];
		                 yourself.

	recipientListPresenter := self newTable
		                          addColumn: (SpCompositeTableColumn new
				                           title: 'Possible sends';
				                           addColumn: ((SpCheckBoxTableColumn
						                             title: ' '
						                             evaluated: [ :anObject | 
							                             selectedMethods includes: anObject ])
						                            onActivation: [ :anObject | 
							                            selectedMethods add: anObject.

							                            listPresenter items:
									                            (selectedMethods 
										                             asSortedCollection:
											                             compiledMethodSortingBlock) ];
						                            onDeactivation: [ :anObject | 
							                            selectedMethods remove: anObject.

							                            listPresenter items:
									                            (selectedMethods 
										                             asSortedCollection:
											                             compiledMethodSortingBlock) ];
						                            yourself);
				                           addColumn:
				                           (SpStringTableColumn evaluated: [ 
					                            :anObject | anObject name ]);
				                           yourself);
		                          sortingBlock: compiledMethodSortingBlock;
		                          yourself.

	codePresenter := self newCode.
	selectorPresenter := self newCode
		                     beForScripting;
		                     yourself.

	innerLayout := self newPanedLayoutTopToBottom
		               add: codePresenter;
		               add: (self newPanedLayoutTopToBottom
				                add: (self newPanedLayoutLeftToRight
						                 add: recipientListPresenter;
						                 add: listPresenter;
						                 positionOfSlider: Float silverRatio;
						                 yourself);
				                add: selectorPresenter;
				                positionOfSlider: Float silverRatio;
				                yourself);
		               positionOfSlider: 1 - Float silverRatio;
		               yourself.

	outerLayout := self newPanedLayoutLeftToRight
		               add: (self newPanedLayoutTopToBottom
				                add: treeTablePresenter;
				                add: listPresenter;
				                positionOfSlider: Float silverRatio;
				                yourself);
		               add: innerLayout;
		               positionOfSlider: 1 - Float silverRatio;
		               yourself.

	self layout: outerLayout
]

{ #category : #initialization }
MTCompiledMethodChoosePresenter >> initializeWindow: aWindow [

	aWindow
		initialExtent: 1 @ Float silverRatio * 1e3;
		title: 'Choose'
]
