Class {
	#name : #MWSession,
	#superclass : #Object,
	#instVars : [
		'stackCounter',
		'decorators',
		'home'
	],
	#classVars : [
		'forbiddenMethods'
	],
	#category : #MethodWrappers
}

{ #category : #API }
MWSession class >> compiledMethods: aCollection thenSelect: methodBlock [

	| methods session |
	methods := aCollection select: [ :each | 
		           (forbiddenMethods includes: each) not and: [ 
			           methodBlock value: each ] ].

	session := self new.

	methods do: [ :each | 
		| decorator |
		decorator := MWDecorator new
			             compiledMethod: each;
			             yourself.

		session add: decorator ].

	^ session
]

{ #category : #API }
MWSession class >> forBaselineClass: aBaselineClass selectMethod: methodBlock [

	| methods |
	methods := (aBaselineClass allPackageNames collect: [ :each | 
		            each asPackage ]) flatCollect: [ :each | each methods ].

	^ self compiledMethods: methods thenSelect: methodBlock
]

{ #category : #API }
MWSession class >> forPackages: aCollection selectMethod: methodBlock [

	| methods |
	methods := aCollection asOrderedCollection flatCollect: [ :each | 
		           each methods ].

	^ self compiledMethods: methods thenSelect: methodBlock
]

{ #category : #API }
MWSession class >> initialize [

	forbiddenMethods := Set new
		                    add: MWDecorator >> #run:with:in:;
		                    add: MWSession >> #run:with:in:context:wrapper:;
		                    add:
			                    MWDecorator >> #run:with:in:context:suspended:;
		                    add:
			                    MWDecorator
			                    >> #run:with:in:context:notSuspended:;
		                    addAll:
			                    (MWHandler >> #run:with:in:context:wrapper:)
				                    allImplementations;
		                    addAll:
			                    (MWHandlerPrePostPlugging
			                     >> #run:with:in:preContext:wrapper:)
				                    allImplementations;
		                    addAll: (MWHandlerPrePostPlugging
			                     >>
				                     #run:with:in:postContext:wrapper:carry:return:)
				                    allImplementations;
		                    add:
			                    MWDecorator >> #valueWithReceiver:arguments:;
		                    add: ProtoObject >> #withArgs:executeMethod:;
		                    add:
			                    MWDecorator >> #withSuspendWrapping:context:;
		                    yourself
]

{ #category : #'instance creation' }
MWSession class >> withAll: aCollection [

	^ self compiledMethods: aCollection thenSelect: [ :each | true ]
]

{ #category : #'instance creation' }
MWSession class >> withAllImplementations: aCollection [

	^ self
		  compiledMethods:
		  (aCollection flatCollect: [ :each | each allImplementations ])
		  thenSelect: [ :each | true ]
]

{ #category : #adding }
MWSession >> add: aDecorator [

	| key |
	key := aDecorator compiledMethod.

	^ (forbiddenMethods includes: key)
		  ifTrue: [ Object new ]
		  ifFalse: [ 
			  decorators at: key ifAbsentPut: [ 
				  aDecorator
					  owner: self;
					  yourself ] ]
]

{ #category : #'*MethodWrappers' }
MWSession >> do: aBlock [

	decorators valuesDo: aBlock
]

{ #category : #initialization }
MWSession >> initialize [

	super initialize.

	decorators := Dictionary new.

	stackCounter := 0
]

{ #category : #'as yet unclassified' }
MWSession >> popContext: aContext [

	stackCounter := stackCounter - 1
]

{ #category : #'as yet unclassified' }
MWSession >> pushContext: aContext [

	stackCounter := stackCounter + 1
]

{ #category : #API }
MWSession >> run: aSelector with: anArray in: aReceiver context: aContext wrapper: aWrapper [

	^ (stackCounter = 0 and: [ aContext hasSender: home ])
		  ifTrue: [ 
			  aWrapper
				  run: aSelector
				  with: anArray
				  in: aReceiver
				  context: aContext
				  notSuspended: true ]
		  ifFalse: [ 
			  aWrapper
				  run: aSelector
				  with: anArray
				  in: aReceiver
				  context: aContext
				  suspended: false ]
]

{ #category : #'*MethodWrappers' }
MWSession >> value: aBlock [

	"Save the current context as 'root' for the following computation."

	home := thisContext.

	^ [ self do: [ :each | each install ] ] value: aBlock then: [ 
		  self do: [ :each | each uninstall ].
		  home := nil ]
]
