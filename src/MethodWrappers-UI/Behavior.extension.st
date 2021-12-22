Extension { #name : #Behavior }

{ #category : #'*MethodWrappers-UI' }
Behavior >> activatedPackages: selectedPackages classes: selectedClasses methods: selectedMethods [

	selectedClasses add: self
]

{ #category : #'*MethodWrappers-UI' }
Behavior >> beInCodePresenter: aCodePresenter [

	^ SpCodePresenter new
		  beForBehavior: self;
		  text: self definitionString;
		  yourself
]

{ #category : #'*MethodWrappers-UI' }
Behavior >> belongsPackages: selectedPackages classes: selectedClasses methods: selectedMethods [

	^ selectedClasses includes: self
]

{ #category : #'*MethodWrappers-UI' }
Behavior >> childrenForCompiledMethodChoosePresenter: aPresenter [

	^ self methods
]

{ #category : #'*MethodWrappers-UI' }
Behavior >> deactivatedPackages: selectedPackages classes: selectedClasses methods: selectedMethods [

	selectedClasses remove: self
]

{ #category : #'*MethodWrappers-UI' }
Behavior >> iconNameForCompiledMethodChoosePresenter: aPresenter [

	^ #class
]
