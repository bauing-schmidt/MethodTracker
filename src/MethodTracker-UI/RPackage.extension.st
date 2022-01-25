Extension { #name : #RPackage }

{ #category : #'*MethodTracker-UI' }
RPackage >> activatedPackages: selectedPackages classes: selectedClasses methods: selectedMethods [

	selectedPackages add: self
]

{ #category : #'*MethodTracker-UI' }
RPackage >> belongsPackages: selectedPackages classes: selectedClasses methods: selectedMethods [

	^ selectedPackages includes: self
]

{ #category : #'*MethodTracker-UI' }
RPackage >> childrenForCompiledMethodChoosePresenter: aPresenter [

	^ self definedClasses asSortedCollection: [ :aClass :anotherClass | 
		  aClass name < anotherClass name ]
]

{ #category : #'*MethodTracker-UI' }
RPackage >> deactivatedPackages: selectedPackages classes: selectedClasses methods: selectedMethods [

	selectedPackages remove: self
]

{ #category : #'*MethodTracker-UI' }
RPackage >> iconNameForCompiledMethodChoosePresenter: aPresenter [

	^ #package
]
