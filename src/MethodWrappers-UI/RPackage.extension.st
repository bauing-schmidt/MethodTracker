Extension { #name : #RPackage }

{ #category : #'*MethodWrappers-UI' }
RPackage >> activatedPackages: selectedPackages classes: selectedClasses methods: selectedMethods [

	selectedPackages add: self
]

{ #category : #'*MethodWrappers-UI' }
RPackage >> belongsPackages: selectedPackages classes: selectedClasses methods: selectedMethods [

	^ selectedPackages includes: self
]

{ #category : #'*MethodWrappers-UI' }
RPackage >> childrenForCompiledMethodChoosePresenter: aPresenter [

	^ self definedClasses asSortedCollection: [ :aClass :anotherClass | 
		  aClass name < anotherClass name ]
]

{ #category : #'*MethodWrappers-UI' }
RPackage >> deactivatedPackages: selectedPackages classes: selectedClasses methods: selectedMethods [

	selectedPackages remove: self
]

{ #category : #'*MethodWrappers-UI' }
RPackage >> iconNameForCompiledMethodChoosePresenter: aPresenter [

	^ #package
]
