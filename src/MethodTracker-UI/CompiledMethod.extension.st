Extension { #name : #CompiledMethod }

{ #category : #'*MethodTracker-UI' }
CompiledMethod >> activatedPackages: selectedPackages classes: selectedClasses methods: selectedMethods [

	selectedMethods add: self
]

{ #category : #'*MethodTracker-UI' }
CompiledMethod >> belongsPackages: selectedPackages classes: selectedClasses methods: selectedMethods [

	^ selectedMethods includes: self
]

{ #category : #'*MethodTracker-UI' }
CompiledMethod >> childrenForCompiledMethodChoosePresenter: aPresenter [

	^ self senders asSet
		  remove: self ifAbsent: [  ];
		  asSortedCollection: [ :aMethod :anotherMethod | 
			  aMethod name < anotherMethod name ]
]

{ #category : #'*MethodTracker-UI' }
CompiledMethod >> deactivatedPackages: selectedPackages classes: selectedClasses methods: selectedMethods [

	selectedMethods remove: self
]

{ #category : #'*MethodTracker-UI' }
CompiledMethod >> iconNameForCompiledMethodChoosePresenter: aPresenter [

	^ #magnitude
]
