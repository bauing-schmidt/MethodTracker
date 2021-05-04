"
I am a presenter for measuring temperatures of compiled methods with respect to the number of times a message is sent.
"
Class {
	#name : #MethodsTemperaturesPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'baselineOfClass',
		'select',
		'heatmap',
		'temperature',
		'do',
		'toolbar',
		'barChart',
		'wrappers',
		'selectors',
		'classIndices',
		'classesSorter',
		'selectorsSorter',
		'barChartSorter',
		'process',
		'measuringInProgress',
		'wrappersHaveBeenInstalledAlready',
		'table',
		'methodsByClassDict',
		'updateInProgress',
		'checkbox'
	],
	#category : #'MethodWrappers-Temperature-UI'
}

{ #category : #specs }
MethodsTemperaturesPresenter class >> defaultSpec [

	^ SpBoxLayout newVertical
		  spacing: 5;
		  add: #toolbar expand: false;
		  add: (SpBoxLayout newHorizontal
				   spacing: 10;
				   add: (SpBoxLayout newVertical
						    spacing: 5;
						    add: 'Behavior block' expand: false;
						    add: #do expand: true;
						    add: 'CompiledMethod select block' expand: false;
						    add: #select expand: true;
						    add: 'Temperature threshold block' expand: false;
						    add: #checkbox expand: false;
						    add: #temperature expand: true;
						    add: 'Selectors ordering block' expand: false;
						    add: #selectorsSorter expand: true;
						    add: 'Classes ordering block' expand: false;
						    add: #classesSorter expand: true;
						    add: 'Bar chart ordering block' expand: false;
						    add: #barChartSorter expand: true;
						    yourself)
				   withConstraints: [ :constraints | constraints width: 300 ];
				   add: #table expand: true;
				   add: #heatmap expand: true;
				   add: #barChart expand: true;
				   yourself)
		  expand: true;
		  yourself
]

{ #category : #specs }
MethodsTemperaturesPresenter class >> on: aBaselineClass [

	^ self basicNew
		  baselineOfClass: aBaselineClass;
		  initialize
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

{ #category : #accessing }
MethodsTemperaturesPresenter >> baselineOfClass: anObject [

	baselineOfClass := anObject
]

{ #category : #'reified blocks' }
MethodsTemperaturesPresenter >> classesSorter [

	^ classesSorter evaluateCompiledMethod
]

{ #category : #charting }
MethodsTemperaturesPresenter >> dataForVisualizations [

	| nrows ncols rowsToKeep columnsToKeep yLabels xLabels matrix |
	"Some one time computed values."
	nrows := selectors size.
	ncols := classIndices size.
	yLabels := Array new: nrows.
	xLabels := Array new: ncols.
	matrix := Array new: nrows.

	"Sets for bookeeping rows and columns that survive to the selection via `thresholdBlock`."
	rowsToKeep := Set new.
	columnsToKeep := Set new.

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
				row at: columnIndex put: aTemperature.

				"If at least one temperature violates the threshold, both the row and  
						   the column should be kept in the final representation."
				(self temperatureBlock value: compiledMethod value: aTemperature) 
					ifTrue: [ 
						rowsToKeep add: rowIndex.
						columnsToKeep add: columnIndex ] ] ].

	"Filtering."
	xLabels := xLabels withIndexSelect: [ :each :index | 
		           columnsToKeep includes: index ].
	yLabels := yLabels withIndexSelect: [ :each :index | 
		           rowsToKeep includes: index ].
	matrix := matrix withIndexSelect: [ :each :index | 
		          rowsToKeep includes: index ].

	"Selecting and returning."
	^ (rowsToKeep isNotEmpty and: [ columnsToKeep isNotEmpty ])
		  ifTrue: [ 
			  Dictionary new
				  at: #xLabels put: (self
						   keep: self topWarmerCompiledMethodsSize
						   of: xLabels
						   accordingTo: checkbox);
				  at: #yLabels put: (self
						   keep: self topWarmerCompiledMethodsSize
						   of: yLabels
						   accordingTo: checkbox);
				  at: #matrix put: ((self
						    keep: self topWarmerCompiledMethodsSize
						    of: matrix
						    accordingTo: checkbox) collect: [ :aRow | 
							   | selected |
							   selected := aRow withIndexSelect: [ :each :index | 
									               columnsToKeep includes: index ].
							   self
								   keep: self topWarmerCompiledMethodsSize
								   of: selected
								   accordingTo: checkbox ]);
				  yourself ]
		  ifFalse: [ Dictionary new ]
]

{ #category : #'default code' }
MethodsTemperaturesPresenter >> defaultCodeForBarChartSorter [

	^ (RBParser parseExpression:
		   '[ :anAssociation :anotherAssociation | anAssociation value > anotherAssociation value ]')
		  formattedCode
]

{ #category : #'default code' }
MethodsTemperaturesPresenter >> defaultCodeForClassesSorter [

	^ (RBParser parseExpression: '[ :aClass :anotherClass | aClass name < anotherClass name ]') formattedCode
]

{ #category : #'default code' }
MethodsTemperaturesPresenter >> defaultCodeForCompiledMethodSelection [

	^ (RBParser parseExpression: '[ :aMethod | PdmAbstractItem allSubclasses includes: aMethod methodClass ]')
		  formattedCode
]

{ #category : #'default code' }
MethodsTemperaturesPresenter >> defaultCodeForDoBehavior [

	^ (RBParser parseExpression: 'PdmSystem start.') formattedCode
]

{ #category : #'default code' }
MethodsTemperaturesPresenter >> defaultCodeForSelectorsSorter [

	^ (RBParser parseExpression: '[ :aWrapper :anotherWrapper | 
		                   aWrapper method selector
		                   < anotherWrapper method selector ]')
		  formattedCode
]

{ #category : #'default code' }
MethodsTemperaturesPresenter >> defaultCodeForTemperatureThreshold [

	^ (RBParser parseExpression:
		   '[ :aCompiledMethod :temperature | temperature > 49 ]')
		  formattedCode
]

{ #category : #'reified blocks' }
MethodsTemperaturesPresenter >> doBlock [

	^ do evaluateCompiledMethod
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

{ #category : #initialization }
MethodsTemperaturesPresenter >> initialize [

	super initialize.

	"The initial phase of temperatures measuring is sleeping."
	measuringInProgress := MethodTemperatureMeasuringPhase sleeping.

	"Also, keep track if the wrappers have been installed or not."
	wrappersHaveBeenInstalledAlready := false.

	"Finally, keep track if an update of visualizations is 
	 in progress to not overlap data creation."
	updateInProgress := false
]

{ #category : #initialization }
MethodsTemperaturesPresenter >> initializePresenters [

	super initializePresenters.

	toolbar := self newToolbar
		           addStyle: 'stToolbar';
		           fillWith: self toolbarActions;
		           yourself.

	select := (self instantiate: SpCodePresenter)
		          withoutLineNumbers;
		          beForScripting;
		          text: self defaultCodeForCompiledMethodSelection;
		          whenSubmitDo: [ :text | self updateVisualizations ];
		          yourself.

	checkbox := self newCheckBox
		            label: ('Restrict to top {1} warmer methods.' format:
					             { self topWarmerCompiledMethodsSize });
		            state: true;
		            whenChangedDo: [ :ev | self updateVisualizations ];
		            yourself.

	temperature := (self instantiate: SpCodePresenter)
		               withoutLineNumbers;
		               beForScripting;
		               text: self defaultCodeForTemperatureThreshold;
		               whenSubmitDo: [ :text | self updateVisualizations ];
		               yourself.

	do := (self instantiate: SpCodePresenter)
		      withoutLineNumbers;
		      beForScripting;
		      text: self defaultCodeForDoBehavior;
		      yourself.

	selectorsSorter := (self instantiate: SpCodePresenter)
		                   withoutLineNumbers;
		                   beForScripting;
		                   text: self defaultCodeForSelectorsSorter;
		                   whenSubmitDo: [ :text | 
			                   self updateVisualizations ];
		                   yourself.

	classesSorter := (self instantiate: SpCodePresenter)
		                 withoutLineNumbers;
		                 beForScripting;
		                 text: self defaultCodeForClassesSorter;
		                 whenSubmitDo: [ :text | self updateVisualizations ];
		                 yourself.

	barChartSorter := (self instantiate: SpCodePresenter)
		                  withoutLineNumbers;
		                  beForScripting;
		                  text: self defaultCodeForBarChartSorter;
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
		         yourself
]

{ #category : #initialization }
MethodsTemperaturesPresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'Methods temperatures';
		initialExtent: 1100 @ 850
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
			aBlock ensure: [ wrappersHaveBeenInstalledAlready := true ] ]
]

{ #category : #charting }
MethodsTemperaturesPresenter >> keep: n of: aCollection accordingTo: aTruthHolder [

	^ aTruthHolder state
		  ifTrue: [ aCollection copyFrom: 1 to: (n min: aCollection size) ]
		  ifFalse: [ aCollection ]
]

{ #category : #initialization }
MethodsTemperaturesPresenter >> measureTemperaturesSpButtonPresenter [

	^ toolbar itemNamed: MeasureMethodsTemperaturesStCommand defaultName
]

{ #category : #accessing }
MethodsTemperaturesPresenter >> methodTemperatureWrappersDo: aBlock [

	 wrappers do: aBlock
]

{ #category : #charting }
MethodsTemperaturesPresenter >> resortWrappers [

	| orderedWrappers |
	selectors := Dictionary new.
	classIndices := Dictionary new.

	orderedWrappers := wrappers asSortedCollection: self selectorsSorter.

	orderedWrappers do: [ :each | 
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
		:anIndex | classIndices at: aClass put: anIndex ]
]

{ #category : #'dispatched commands' }
MethodsTemperaturesPresenter >> runInstallMethodTemperatureWrappersStCommand: aCommand [

	self installingWrappers: [ "First, allocate a wrapper for each compiled method selected by
		 the given block (edited in the corresponding block presenter)."
		wrappers := MethodTemperatureWrapper
			            forBaselineClass: baselineOfClass
			            selectMethod: self selectBlock.

		"Second, install the wrappers (possibly time-consuming)."
		self methodTemperatureWrappersDo: [ :each | each install ] ]
]

{ #category : #'dispatched commands' }
MethodsTemperaturesPresenter >> runMeasureMethodsTemperaturesStCommand: aCommand [

	  measuringInProgress := measuringInProgress toggle
			runMeasureMethodsTemperaturesStCommand: aCommand forMethodsTemperaturesPresenter: self;
			yourself
]

{ #category : #charting }
MethodsTemperaturesPresenter >> scaleForHeatmap [

	^ NSScale linear
		  range: #( white black );
		  yourself
]

{ #category : #'reified blocks' }
MethodsTemperaturesPresenter >> selectBlock [

	^ select evaluateCompiledMethod
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

	^ 25
]

{ #category : #charting }
MethodsTemperaturesPresenter >> updateVisualizations [

	self visualizationsUpdating: [ 
		| aDictionary |
		aDictionary := self
			               resortWrappers;
			               dataForVisualizations.

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

	wrappers ifNotNil: [ 
		wrappers do: [ :each | each uninstall ].
		wrappers := nil.
		wrappersHaveBeenInstalledAlready := false ]
]

{ #category : #charting }
MethodsTemperaturesPresenter >> xLabels: xLabels yLabels: yLabels matrix: matrix [

	| anHeatmap barPlot chart compiledMethods |
	anHeatmap := RSHeatmap new
		             scale: self scaleForHeatmap;
		             xLabels: xLabels;
		             yLabels: yLabels;
		             show: matrix modelBlock: [ :aSelector :aClass | 
			             [ aClass >> aSelector ]
				             on: KeyNotFound
				             do: [ nil ] ];
		             yourself.

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
		           yourself.
	barPlot shape cornerRadius: 3.

	chart := RSChart new
		         addPlot: barPlot;
		         addDecoration: RSVerticalTick new;
		         build;
		         yourself.

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
		heatmap: anHeatmap;
		barChart: chart
]
