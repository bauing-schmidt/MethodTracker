Extension { #name : #Behavior }

{ #category : #'*MethodTracker-UI' }
Behavior >> activatedPackages: selectedPackages classes: selectedClasses methods: selectedMethods [

	selectedClasses add: self
]

{ #category : #'*MethodTracker-UI' }
Behavior >> belongsPackages: selectedPackages classes: selectedClasses methods: selectedMethods [

	^ selectedClasses includes: self
]

{ #category : #'*MethodTracker-UI' }
Behavior >> childrenForCompiledMethodChoosePresenter: aPresenter [

	^ self methods
]

{ #category : #'*MethodTracker-UI' }
Behavior >> deactivatedPackages: selectedPackages classes: selectedClasses methods: selectedMethods [

	selectedClasses remove: self
]

{ #category : #'*MethodTracker-UI' }
Behavior >> iconNameForCompiledMethodChoosePresenter: aPresenter [

	^ #class
]
