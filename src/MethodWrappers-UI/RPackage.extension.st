Extension { #name : #RPackage }

{ #category : #'*MethodWrappers-UI' }
RPackage >> childrenForCompiledMethodChoosePresenter: aPresenter [

	^ self definedClasses asSortedCollection: [ :aClass :anotherClass | 
		  aClass name < anotherClass name ]
]
