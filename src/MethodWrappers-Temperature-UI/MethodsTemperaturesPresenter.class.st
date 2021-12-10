"
I am a presenter for measuring temperatures of compiled methods with respect to the number of times a message is sent.
"
Class {
	#name : #MethodsTemperaturesPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'select',
		'heatmap',
		'temperature',
		'do',
		'toolbar',
		'barChart',
		'wrappers',
		'classesSorter',
		'selectorsSorter',
		'barChartSorter',
		'process',
		'measuringInProgress',
		'wrappersHaveBeenInstalledAlready',
		'table',
		'methodsByClassDict',
		'updateInProgress',
		'checkbox',
		'packagesList',
		'packageNameText',
		'selectedPackages',
		'allPackages',
		'checkboxInstallOnAllMethods',
		'configuration',
		'callsLog',
		'checkboxShowMessageSendsArgs',
		'checkboxSkipTestPackages'
	],
	#category : #'MethodWrappers-Temperature-UI'
}

{ #category : #configuration }
MethodsTemperaturesPresenter class >> defaultConfFileReference [

	^ 'method-temperatures-conf.ston' asFileReference
]

{ #category : #configuration }
MethodsTemperaturesPresenter class >> defaultConfScript [

	<script>
	self defaultConfFileReference writeStreamDo: [ :aStream | 
		STON put: self defaultConfiguration onStreamPretty: aStream ]
]

{ #category : #configuration }
MethodsTemperaturesPresenter class >> defaultConfiguration [

	| conf |
	conf := Dictionary new.
	conf at: #installOnAllMethods put: true.
	conf at: #topWarmerMethods put: 30.
	conf at: #selectTopWarmerMethods put: true.
	conf at: #showMessageSendsArgs put: false.
	conf
		at: #defaultCodeForBarChartSorter
		put:
		'[ :anAssociation :anotherAssociation | anAssociation value > anotherAssociation value ]'.
	conf
		at: #defaultCodeForClassesSorter
		put: '[ :aClass :anotherClass | aClass name < anotherClass name ]'.
	conf
		at: #defaultCodeForCompiledMethodSelection
		put: '[ :aMethod | true ]'.
	conf at: #defaultCodeForDoBehavior put: 'PdmSystem start.'.
	conf
		at: #defaultCodeForSelectorsSorter
		put:
		'[ :aWrapper :anotherWrapper | aWrapper method selector < anotherWrapper method selector ]'.
	conf
		at: #defaultCodeForTemperatureThreshold
		put: '[ :aCompiledMethod :temperature | temperature > 49 ]'.

	conf at: #selectedPackageNames put: { 'Documaps'. 'Glorp' }.

	^ conf
]

{ #category : #specs }
MethodsTemperaturesPresenter class >> defaultSpec [

	^ SpBoxLayout newVertical
		  spacing: 5;
		  add: #toolbar expand: false;
		  add: (SpPanedLayout newLeftToRight
				   positionOfSlider: 380;
				   add: (SpBoxLayout newVertical
						    spacing: 5;
						    add: 'Behavior block' expand: false;
						    add: #do expand: true;
						    add: 'Packages selection' expand: false;
						    add: #checkboxInstallOnAllMethods expand: false;
						    add: #checkboxSkipTestPackages expand: false;
						    add: #packagesList expand: true;
						    add: #packageNameText expand: false;
						    add: 'CompiledMethod select block' expand: false;
						    add: #select expand: true;
						    add: 'Temperature threshold block' expand: false;
						    add: #temperature expand: true;
						    add: 'Selectors ordering block' expand: false;
						    add: #selectorsSorter expand: true;
						    add: 'Classes ordering block' expand: false;
						    add: #classesSorter expand: true;
						    add: 'Bar chart ordering block' expand: false;
						    add: #barChartSorter expand: true;
						    yourself);
				   add: (SpPanedLayout newLeftToRight
						    add: (SpBoxLayout newTopToBottom
								     add: #checkboxShowMessageSendsArgs expand: false;
								     add: #callsLog expand: true;
								     yourself);
						    add: (SpPanedLayout newLeftToRight
								     add: (SpBoxLayout newTopToBottom
										      add: #checkbox expand: false;
										      add: #table;
										      yourself);
								     add: (SpPanedLayout newTopToBottom
										      add: #heatmap;
										      add: #barChart;
										      yourself);
								     yourself);
						    yourself);
				   yourself)
		  expand: true;
		  yourself
]

{ #category : #'dispatched commands' }
MethodsTemperaturesPresenter >> applyConfiguration [

	checkboxInstallOnAllMethods
		label: ('Wrap all methods of selected packages.' format:
					 { self topWarmerCompiledMethodsSize });
		state: (configuration at: #installOnAllMethods).

	selectedPackages := Set withAll: (allPackages select: [ :each | 
			                     (configuration at: #selectedPackageNames)
				                     inject: false
				                     into: [ :acc :name | 
					                     | aBoolean |
					                     aBoolean := each name asLowercase 
						                                 includesSubstring:
						                                 name asLowercase.
					                     acc | aBoolean ] ]).

	select text: self defaultCodeForCompiledMethodSelection.

	checkbox
		label: ('Restrict to top {1} warmer methods.' format:
					 { self topWarmerCompiledMethodsSize });
		state: (configuration at: #selectTopWarmerMethods).

	checkboxShowMessageSendsArgs state:
		(configuration at: #showMessageSendsArgs).

	checkboxSkipTestPackages state: (configuration at: #skipTestPackages ifAbsent: [ false ]).

	temperature text: self defaultCodeForTemperatureThreshold.

	do text: self defaultCodeForDoBehavior.

	selectorsSorter text: self defaultCodeForSelectorsSorter.

	classesSorter text: self defaultCodeForClassesSorter.

	barChartSorter text: self defaultCodeForBarChartSorter
]

{ #category : #accessing }
MethodsTemperaturesPresenter >> barChart: aChart [

	barChart script: [ :view | 
		view
			addShape: aChart canvas asShape;
			zoomToFit;
			addInteraction: RSCanvasController ]
]

{ #category : #'reified blocks' }
MethodsTemperaturesPresenter >> barChartSorter [

	^ barChartSorter evaluateCompiledMethod
]

{ #category : #'reified blocks' }
MethodsTemperaturesPresenter >> classesSorter [

	^ classesSorter evaluateCompiledMethod
]

{ #category : #'selection support' }
MethodsTemperaturesPresenter >> currentConfiguration [

	| conf |
	conf := Dictionary new.
	conf at: #installOnAllMethods put: checkboxInstallOnAllMethods state.
	conf at: #topWarmerMethods put: (configuration at: #topWarmerMethods).
	conf at: #selectTopWarmerMethods put: checkbox state.
	conf at: #showMessageSendsArgs put: checkboxShowMessageSendsArgs state.
	conf at: #skipTestPackages put: checkboxSkipTestPackages state.
	conf at: #defaultCodeForBarChartSorter put: barChartSorter text.
	conf at: #defaultCodeForClassesSorter put: classesSorter text.
	conf at: #defaultCodeForCompiledMethodSelection put: select text.
	conf at: #defaultCodeForDoBehavior put: do text.
	conf at: #defaultCodeForSelectorsSorter put: selectorsSorter text.
	conf at: #defaultCodeForTemperatureThreshold put: temperature text.

	conf
		at: #selectedPackageNames
		put: (selectedPackages asArray collect: [ :each | each name ]).

	^ conf
]

{ #category : #charting }
MethodsTemperaturesPresenter >> dataForVisualizationsSelectors: selectors classesIndices: classIndices [

	| nrows ncols yLabels xLabels matrix |
	"Some one time computed values."
	nrows := selectors size.
	ncols := classIndices size.
	yLabels := Array new: nrows.
	xLabels := Array new: ncols.
	matrix := Array new: nrows.

	"Doing."
	selectors keysAndValuesDo: [ 
		:aSelector 
		:anAssociationOfSelectorIndexAndTemperaturesDictionary | 
		| row rowIndex |
		"Get the row index which equals the `aSelector` index."
		rowIndex := anAssociationOfSelectorIndexAndTemperaturesDictionary
			            key.

		"Record the `aSelector` as label for the y-axis (aka rows)."
		yLabels at: rowIndex put: aSelector.

		"Allocate a row for `aSelector`, initially with `ncols` zeros."
		row := matrix at: rowIndex put: (Array new: ncols withAll: 0).

		anAssociationOfSelectorIndexAndTemperaturesDictionary value 
			keysAndValuesDo: [ :aClass :aTemperature | 
				| columnIndex compiledMethod |
				"Get the compiled method to be passed to the threshold block."
				compiledMethod := aClass >> aSelector.

				"Get the column index of `aClass`."
				columnIndex := classIndices at: aClass.

				"Record the `aClass` as label for the x-axis (aka columns)."
				xLabels at: columnIndex put: aClass.

				"Store the temperature in the corresponding matrix position, finally."
				row at: columnIndex put: aTemperature ] ].

	^ (xLabels isNotEmpty and: [ yLabels isNotEmpty ])
		  ifTrue: [ 
			  Dictionary new
				  at: #xLabels put: xLabels;
				  at: #yLabels put: yLabels;
				  at: #matrix put: matrix;
				  yourself ]
		  ifFalse: [ Dictionary new ]
]

{ #category : #'default code' }
MethodsTemperaturesPresenter >> defaultCodeForBarChartSorter [

	^ configuration at: #defaultCodeForBarChartSorter
]

{ #category : #'default code' }
MethodsTemperaturesPresenter >> defaultCodeForClassesSorter [

	^ configuration at: #defaultCodeForClassesSorter
]

{ #category : #'default code' }
MethodsTemperaturesPresenter >> defaultCodeForCompiledMethodSelection [

	^ configuration at: #defaultCodeForCompiledMethodSelection
]

{ #category : #'default code' }
MethodsTemperaturesPresenter >> defaultCodeForDoBehavior [

	^ configuration at: #defaultCodeForDoBehavior
]

{ #category : #'default code' }
MethodsTemperaturesPresenter >> defaultCodeForSelectorsSorter [

	^ configuration at: #defaultCodeForSelectorsSorter
]

{ #category : #'default code' }
MethodsTemperaturesPresenter >> defaultCodeForTemperatureThreshold [

	^ configuration at: #defaultCodeForTemperatureThreshold
]

{ #category : #'reified blocks' }
MethodsTemperaturesPresenter >> doBlock [

	^ do evaluateCompiledMethod
]

{ #category : #charting }
MethodsTemperaturesPresenter >> filteredWrappers [

	| thresholdBlock selectedWrappers orderedWrappers filteredWrappers |
	thresholdBlock := self temperatureBlock.

	selectedWrappers := wrappers select: [ :each | 
		                    thresholdBlock
			                    value: each method
			                    value: each count ].

	orderedWrappers := selectedWrappers asSortedCollection: [ 
		                   :aWrapper 
		                   :anotherWrapper | 
		                   aWrapper count > anotherWrapper count ].

	filteredWrappers := self
		                    keep: self topWarmerCompiledMethodsSize
		                    of: orderedWrappers
		                    accordingTo: checkbox.

	^ filteredWrappers asSortedCollection: self selectorsSorter
]

{ #category : #accessing }
MethodsTemperaturesPresenter >> heatmap: anHeatmap [

	heatmap script: [ :view | 
		view
			addShape: anHeatmap canvas asShape;
			addInteraction: RSCanvasController;
			zoomToFit;
			yourself ]
]

{ #category : #charting }
MethodsTemperaturesPresenter >> heatmap: anHeatmap xLabels: xLabels yLabels: yLabels matrix: matrix [

	self heatmap: (anHeatmap
			 scale: self scaleForHeatmap;
			 xLabels: xLabels;
			 yLabels: yLabels;
			 show: matrix modelBlock: [ :aSelector :aClass | 
				 [ aClass >> aSelector ]
					 on: KeyNotFound
					 do: [ nil ] ];
			 yourself)
]

{ #category : #initialization }
MethodsTemperaturesPresenter >> initialize [

	"The initial phase of temperatures measuring is sleeping."

	measuringInProgress := MethodTemperatureMeasuringPhase sleeping.

	"Also, keep track if the wrappers have been installed or not."
	wrappers := OrderedCollection new.
	wrappersHaveBeenInstalledAlready := false.

	"Finally, keep track if an update of visualizations is 
	 in progress to not overlap data creation."
	updateInProgress := false.

	"Now we can initialize subpresenters via our super implementation"
	super initialize
]

{ #category : #initialization }
MethodsTemperaturesPresenter >> initializePresenters [

	super initializePresenters.

	toolbar := self newToolbar
		           addStyle: 'stToolbar';
		           fillWith: self toolbarActions;
		           yourself.

	checkboxInstallOnAllMethods := self newCheckBox
		                               whenChangedDo: [ :aBoolean | 
			                               select enabled: aBoolean not ];
		                               yourself.

	checkboxSkipTestPackages := self newCheckBox
		                            label: 'Skip test packages';
		                            whenChangedDo: [ :aBoolean | 
			                            self 
				                            refreshPackagesTableWhenTextChanges:
					                            packageNameText text ];
		                            yourself.

	allPackages := RPackageOrganizer default packages asOrderedCollection 
		               sort: [ :a :b | a name < b name ].
	selectedPackages := Set empty.
	packagesList := self newTable addColumn: (SpCompositeTableColumn new
			                 addColumn: (SpCheckBoxTableColumn new
					                  evaluated: [ :item | 
						                  selectedPackages includes: item ];
					                  onActivation: [ :item | 
						                  selectedPackages add: item ];
					                  onDeactivation: [ :item | 
						                  selectedPackages remove: item ifAbsent: [  ] ];
					                  width:
						                  20 * self currentWorld displayScaleFactor;
					                  yourself);
			                 addColumn: (SpImageTableColumn new
					                  width: 20;
					                  evaluated: [ :each | self iconNamed: #package ];
					                  yourself);
			                 addColumn: (SpStringTableColumn new
					                  evaluated: #name;
					                  yourself);
			                 yourself).

	packageNameText := self newTextInput
		                   placeholder: 'Enter a package name';
		                   autoAccept: true;
		                   whenTextChangedDo: [ :text | 
			                   self refreshPackagesTableWhenTextChanges: text ].

	self refreshPackagesTableWhenTextChanges: ''.

	select := (self instantiate: SpCodePresenter)
		          withoutLineNumbers;
		          beForScripting;
		          enabled: checkboxInstallOnAllMethods state not;
		          whenSubmitDo: [ :text | self updateVisualizations ];
		          yourself.

	checkbox := self newCheckBox
		            whenChangedDo: [ :ev | self updateVisualizations ];
		            yourself.

	temperature := (self instantiate: SpCodePresenter)
		               withoutLineNumbers;
		               beForScripting;
		               whenSubmitDo: [ :text | self updateVisualizations ];
		               yourself.

	do := (self instantiate: SpCodePresenter)
		      withoutLineNumbers;
		      beForScripting;
		      yourself.

	selectorsSorter := (self instantiate: SpCodePresenter)
		                   withoutLineNumbers;
		                   beForScripting;
		                   whenSubmitDo: [ :text | 
			                   self updateVisualizations ];
		                   yourself.

	classesSorter := (self instantiate: SpCodePresenter)
		                 withoutLineNumbers;
		                 beForScripting;
		                 whenSubmitDo: [ :text | self updateVisualizations ];
		                 yourself.

	barChartSorter := (self instantiate: SpCodePresenter)
		                  withoutLineNumbers;
		                  beForScripting;
		                  whenSubmitDo: [ :text | self updateVisualizations ];
		                  yourself.

	heatmap := self instantiate: SpRoassalPresenter.
	barChart := self instantiate: SpRoassalPresenter.

	table := self newTreeTable
		         addColumn: (SpStringTableColumn
				          title: 'Compiled methods by class'
				          evaluated: [ :anObject | 
					          anObject isCompiledMethod
						          ifTrue: [ anObject selector ]
						          ifFalse: [ anObject name ] ]);
		         addColumn:
			         (SpStringTableColumn
				          title: 'Temperature'
				          evaluated: [ :anObject | 
					          anObject isCompiledMethod
						          ifTrue: [ 
							          methodsByClassDict
								          at: anObject methodClass
								          ifPresent: [ :associations | 
									          | index |
									          index := associations findFirst: [ :each | 
											                   each key = anObject ].
									          (associations at: index) value ] ]
						          ifFalse: [ String empty ] ]);
		         children: [ :aClass | 
			         methodsByClassDict
				         at: aClass
				         ifPresent: [ :associations | associations collect: #key ]
				         ifAbsent: [ #(  ) ] ];
		         beResizable;
		         activateOnDoubleClick;
		         whenActivatedDo: [ :selection | 
			         selection selectedItem browse ];
		         yourself.

	checkboxShowMessageSendsArgs := self newCheckBox
		                                label:
			                                'Show arguments of message sends';
		                                yourself.

	callsLog := (self instantiate: SpListPresenter)
		            sortingBlock: [ :aWrapper :anotherWrapper | 
			            aWrapper callsLog last key logicalStart
			            > anotherWrapper callsLog last key logicalStart ];
		            display: [ :aWrapper | 
			            aWrapper callsLog last in: [ :anAssoc | 
					            String streamContents: [ :aStream | 
							            | msg |
							            aStream
								            nextPutAll: anAssoc key start asTimeString;
								            nextPutAll: ': '.
							            msg := checkboxShowMessageSendsArgs state
								                   ifTrue: [ anAssoc value asString ]
								                   ifFalse: [ anAssoc value selector ].
							            aStream nextPutAll: msg ] ] ];
		            yourself.

	"Load a possible cconfiguration"
	configuration := self loadDefaultConfiguration.
	self applyConfiguration
]

{ #category : #initialization }
MethodsTemperaturesPresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'Methods temperatures';
		initialExtent: 1100 @ 850
]

{ #category : #initialization }
MethodsTemperaturesPresenter >> installWrappersSpButtonPresenter [

	^ toolbar itemNamed:
		  InstallMethodTemperatureWrappersStCommand defaultName
]

{ #category : #'dispatched commands' }
MethodsTemperaturesPresenter >> installingWrappers: aBlock [

	wrappersHaveBeenInstalledAlready
		ifTrue: [ 
			| msg |
			msg := 'Wrappers have been installed already on {1} compiled methods. Skipping...' 
				       format: { wrappers size }.
			Warning signal: msg ]
		ifFalse: [ 
			aBlock ensure: [ 
				wrappersHaveBeenInstalledAlready := true.
				
				self installWrappersSpButtonPresenter
					badge: 'i';
					update ] ]
]

{ #category : #charting }
MethodsTemperaturesPresenter >> keep: n of: aCollection accordingTo: aTruthHolder [

	^ aTruthHolder state
		  ifTrue: [ aCollection copyFrom: 1 to: (n min: aCollection size) ]
		  ifFalse: [ aCollection ]
]

{ #category : #running }
MethodsTemperaturesPresenter >> loadConfigurationFromFileReference: fr [

	^ fr readStreamDo: [ :aStream | STON fromStream: aStream ]
]

{ #category : #running }
MethodsTemperaturesPresenter >> loadDefaultConfiguration [

	^ self class defaultConfFileReference
		  ifExists: [ :fr | self loadConfigurationFromFileReference: fr ]
		  ifAbsent: [ self class defaultConfiguration ]
]

{ #category : #initialization }
MethodsTemperaturesPresenter >> measureTemperaturesSpButtonPresenter [

	^ toolbar itemNamed: MeasureMethodsTemperaturesStCommand defaultName
]

{ #category : #accessing }
MethodsTemperaturesPresenter >> methodTemperatureWrappersDo: aBlock [

	 wrappers do: aBlock
]

{ #category : #'dispatched commands' }
MethodsTemperaturesPresenter >> overlappings: aCollection do: aBlock [

	aCollection ifNotEmpty: [ 
		| i j link |
		link := nil.

		i := 1.
		[ i <= aCollection size ] whileTrue: [ 
			| end current start each |
			each := aCollection at: i.

			start := each key logicalStart.
			end := each key logicalEnd.

			[ link isNotNil and: [ link value key logicalEnd <= start ] ] 
				whileTrue: [ link := link nextLink ].

			link := each ~~> link.

			j := i + 1.
			[ 
			j <= aCollection size and: [ 
				current := aCollection at: j.
				current key logicalStart < end ] ] whileTrue: [ 
				link := current ~~> link.

				current value
					ifSelfSend: [  ]
					ifNotSelfSend: [ end := end min: current key logicalEnd ].

				j := j + 1 ].


			aBlock value: (OrderedCollection new
					 addAll: link reversed;
					 yourself).

			i := j ] ]
]

{ #category : #initialization }
MethodsTemperaturesPresenter >> refreshPackagesTableWhenTextChanges: aString [

	| packages |
	packages := aString ifEmpty: [ allPackages ] ifNotEmpty: [ 
		            allPackages select: [ :currPackage | 
			            | bool |
			            bool := aString match: currPackage name asString.
			            bool and: [ 
				            checkboxSkipTestPackages state
					            ifTrue: [ currPackage isTestPackage not ]
					            ifFalse: [ true ] ] ] ].
		
	packagesList items: packages
]

{ #category : #charting }
MethodsTemperaturesPresenter >> resortWrappers [

	| selectors classIndices |
	selectors := Dictionary new.
	classIndices := Dictionary new.

	self filteredWrappers do: [ :each | 
		| selectorAssoc aClass |
		aClass := each method methodClass.

		"Get the association with the (row) index of the selector and the companion row of measurements,
		 creating that association in case of an unseen-so-far selector."
		selectorAssoc := selectors
			                 at: each method selector
			                 ifAbsentPut: [ 
			                 selectors size + 1 -> Dictionary new ].

		"Store the measured temperature, like setting a matrix element."
		selectorAssoc value in: [ :aDictionary | 
			aDictionary
				at: aClass
				ifPresent: [ 
					| msg |
					msg := 'The compiled method {} has been measured twice.' format:
						       { each method name }.
					Error signal: msg ]
				ifAbsentPut: [ each count ] ].

		"Record the next index that is available for `aClass` if it hasn't one yet."
		classIndices at: aClass ifAbsentPut: [ classIndices size + 1 ] ].

	"(Re)order the indices associated to classes in order to provide columns 
			   ordered by classes' names, by updating the `classIndex` dictionary."
	(classIndices keys sorted: self classesSorter) withIndexDo: [ 
		:aClass 
		:anIndex | classIndices at: aClass put: anIndex ].

	^ selectors -> classIndices
]

{ #category : #'dispatched commands' }
MethodsTemperaturesPresenter >> runConfLoadTemperatureMethodsStCommand: aCommand [

	| dialog |
	dialog := FileDialogWindow new
		          title: 'Load conf';
		          validExtensions: #( ston );
		          answerFileEntry.

	dialog openModal answer ifNotNil: [ :answer | 
		configuration := self loadConfigurationFromFileReference:
			                 answer asFileReference.

		self applyConfiguration ]
]

{ #category : #'dispatched commands' }
MethodsTemperaturesPresenter >> runConfSaveTemperatureMethodsStCommand: aCommand [

	| dialog |
	dialog := FileDialogWindow new
		          title: 'Save conf';
		          validExtensions: #( ston );
		          answerSaveFile.

	dialog openModal answer ifNotNil: [ :answer | 
		answer asFileReference writeStreamDo: [ :aStream | 
			STON put: self currentConfiguration onStreamPretty: aStream ] ]
]

{ #category : #'dispatched commands' }
MethodsTemperaturesPresenter >> runDoitWrappedTemperatureMethodsStCommand: aCommand [

	self doBlock value
]

{ #category : #'dispatched commands' }
MethodsTemperaturesPresenter >> runInstallMethodTemperatureWrappersStCommand: aCommand [

	self installingWrappers: [ "First, allocate a wrapper for each compiled method selected by
		 the given block (edited in the corresponding block presenter)."
		wrappers := MWHandlerExecution
			            tick: 0;
			            forPackages: selectedPackages
			            selectMethod: [ :aMethod | 
				            self selectBlock
					            value: aMethod
					            value: selectedPackages ].

		"Second, install the wrappers (possibly time-consuming)."
		self methodTemperatureWrappersDo: [ :each | each install ] ]
]

{ #category : #'dispatched commands' }
MethodsTemperaturesPresenter >> runMeasureMethodsTemperaturesStCommand: aCommand [

	  measuringInProgress := measuringInProgress toggle
			runMeasureMethodsTemperaturesStCommand: aCommand forMethodsTemperaturesPresenter: self;
			yourself
]

{ #category : #'dispatched commands' }
MethodsTemperaturesPresenter >> runSequenceDiagramMethodsTemperaturesStCommand: aCommand [

	| orderedCalls shapes stackSelected objectsSeenSoFar |
	orderedCalls := MWHandlerExecution callsLog.

	shapes := OrderedCollection new.
	objectsSeenSoFar := IdentityDictionary new.

	stackSelected := SpConfirmDialog new
		                 title: 'Question';
		                 label: 'Stack interactions vertically?';
		                 acceptLabel: 'Yes';
		                 cancelLabel: 'No';
		                 openModalWithSpec.

	stackSelected
		ifTrue: [ 
			| previousOverlappings previousHeaders |
			previousOverlappings := OrderedCollection new.
			previousHeaders := OrderedCollection new.

			self overlappings: orderedCalls do: [ :overlappings | 
					| builder |
					builder := RSUMLSequenceBuilder new
						           objectsSeenSoFar: objectsSeenSoFar;
						           previousMessagesSends: previousOverlappings;
						           previousHeaders: previousHeaders;
						           messagesSends: overlappings;
						           build;
						           yourself.

					previousHeaders := builder modelDescriptor columns.
					previousOverlappings := overlappings.

					builder shapes ifNotEmpty: [ :nestedShapes | 
						shapes add: (RSComposite new
								 shapes: nestedShapes;
								 yourself) ] ] ];
		ifFalse: [ 
			| builder |
			builder := RSUMLSequenceBuilder new
				           objectsSeenSoFar: objectsSeenSoFar;
				           messagesSends: orderedCalls;
				           previousHeaders: OrderedCollection new;
				           previousMessagesSends: OrderedCollection new;
				           build;
				           yourself.

			shapes add: builder canvas asShape ].

	RSVerticalLineLayout new
		verticalGap: -5;
		alignLeft;
		on: shapes.

	RSCanvas new
		addAll: shapes;
		zoomToFit;
		"in: [ :c | 
			c svgExporter
				zoomToShapes;
				export ];"
		addInteraction: RSCanvasController new;
		open
]

{ #category : #charting }
MethodsTemperaturesPresenter >> scaleForHeatmap [

	^ NSScale linear
		  range: #( white black );
		  yourself
]

{ #category : #'reified blocks' }
MethodsTemperaturesPresenter >> selectBlock [

	^ checkboxInstallOnAllMethods state 
		ifTrue: [ [ :aMethod :packages | true ] ] 
		ifFalse: [ select evaluateCompiledMethod ]
]

{ #category : #'reified blocks' }
MethodsTemperaturesPresenter >> selectorsSorter [

	^ selectorsSorter evaluateCompiledMethod
]

{ #category : #'reified blocks' }
MethodsTemperaturesPresenter >> temperatureBlock [

	^ temperature evaluateCompiledMethod
]

{ #category : #initialization }
MethodsTemperaturesPresenter >> toolbarActions [

	| aGroup commandClasses |
	aGroup := CmCommandGroup forSpec.
	commandClasses := MethodsTemperaturesStCommand allSubclasses sorted: [ :a :b | a priority <= b priority ].
	commandClasses do: [ :aCommandClass | aGroup register: (aCommandClass forSpecContext: self) ].

	^ CmCommandGroup forSpec
		  register: aGroup;
		  yourself
]

{ #category : #charting }
MethodsTemperaturesPresenter >> topWarmerCompiledMethodsSize [

	^ configuration at: #topWarmerMethods
]

{ #category : #charting }
MethodsTemperaturesPresenter >> updateVisualizations [

	self visualizationsUpdating: [ 
		| aDictionary anAssociation |
		anAssociation := self resortWrappers.

		aDictionary := self
			               dataForVisualizationsSelectors: anAssociation key
			               classesIndices: anAssociation value.

		callsLog
			items: (wrappers select: [ :each | each callsLog isNotEmpty ]);
			updateList.

		aDictionary isEmpty ifFalse: [ 
			self
				xLabels: (aDictionary at: #xLabels)
				yLabels: (aDictionary at: #yLabels)
				matrix: (aDictionary at: #matrix) ] ]
]

{ #category : #charting }
MethodsTemperaturesPresenter >> visualizationsUpdating: aBlock [

	updateInProgress ifFalse: [ 
		updateInProgress := true.
		aBlock ensure: [ updateInProgress := false ] ]
]

{ #category : #initialization }
MethodsTemperaturesPresenter >> windowIsClosing [

	super windowIsClosing.

	wrappers
		do: [ :each | [ each uninstall ] onDNU: #uninstall do: [ :ex |  ] ];
		removeAll.

	wrappersHaveBeenInstalledAlready := false
]

{ #category : #charting }
MethodsTemperaturesPresenter >> xLabels: xLabels yLabels: yLabels matrix: matrix [

	| barPlot chart compiledMethods |
	compiledMethods := SortedCollection sortUsing: self barChartSorter.
	methodsByClassDict := Dictionary new.

	xLabels withIndexDo: [ :aClass :columnIndex | 
		yLabels withIndexDo: [ :aSelector :rowIndex | 
			| cm |
			cm := [ aClass >> aSelector ]
				      on: KeyNotFound
				      do: [ nil ].
			cm ifNotNil: [ 
				| temp |
				temp := (matrix at: rowIndex) at: columnIndex.
				compiledMethods add: cm -> temp ] ] ].

	(self
		 keep: self topWarmerCompiledMethodsSize
		 of: compiledMethods
		 accordingTo: checkbox) do: [ :each | 
		| cm methods |
		cm := each key.
		methods := methodsByClassDict
			           at: cm methodClass
			           ifAbsentPut: [ OrderedCollection new ].
		methods add: each ].

	barPlot := RSBarPlot new
		           color: (Color black alpha: 0.3);
		           y: (compiledMethods collect: #value);
		           yourself: [ :plot | 
			           plot shape cornerRadius: Float goldenRatio * 2 ].

	chart := RSChart new
		         addPlot: barPlot;
		         addDecoration: RSVerticalTick new;
		         build;
		         yourself.

	"The following iteration can only be done after the message `build` has been sent to the chart."
	barPlot bars
		with: (compiledMethods collect: #key)
		do: [ :aBar :aCompiledMethod | 
			aBar
				model: aCompiledMethod -> aBar model;
				addInteraction: RSPopup new;
				when: RSMouseClick do: [ :e | e shape model key browse ] ].

	table
		roots: xLabels;
		expandAll.

	self
		heatmap: RSHeatmap new
		xLabels: xLabels
		yLabels: yLabels
		matrix: matrix.

	self barChart: chart
]
