Extension { #name : #CompiledMethod }

{ #category : #'*MethodWrappers-UI' }
CompiledMethod >> childrenForCompiledMethodChoosePresenter: aPresenter [

	^ self senders asSet
		  remove: self ifAbsent: [  ];
		  asSortedCollection: [ :aMethod :anotherMethod | 
			  aMethod name < anotherMethod name ]
]
