Extension { #name : #CompiledMethod }

{ #category : #'*MethodWrappers-UI' }
CompiledMethod >> activatedPackages: selectedPackages classes: selectedClasses methods: selectedMethods [

	selectedMethods add: self
]

{ #category : #'*MethodWrappers-UI' }
CompiledMethod >> belongsPackages: selectedPackages classes: selectedClasses methods: selectedMethods [

	^ selectedMethods includes: self
]

{ #category : #'*MethodWrappers-UI' }
CompiledMethod >> childrenForCompiledMethodChoosePresenter: aPresenter [

	^ self senders asSet
		  remove: self ifAbsent: [  ];
		  asSortedCollection: [ :aMethod :anotherMethod | 
			  aMethod name < anotherMethod name ]
]

{ #category : #'*MethodWrappers-UI' }
CompiledMethod >> deactivatedPackages: selectedPackages classes: selectedClasses methods: selectedMethods [

	selectedMethods remove: self
]

{ #category : #'*MethodWrappers-UI' }
CompiledMethod >> iconNameForCompiledMethodChoosePresenter: aPresenter [

	^ #magnitude
]
