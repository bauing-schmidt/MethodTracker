Class {
	#name : #MTSession,
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
MTSession class >> compiledMethods: aCollection thenSelect: methodBlock [

	| methods session |
	methods := aCollection select: [ :each | 
		           (forbiddenMethods includes: each) not and: [ 
			           methodBlock value: each ] ].

	session := self new.

	methods do: [ :each | 
		| decorator |
		decorator := MTDecorator new
			             compiledMethod: each;
			             yourself.

		session add: decorator ].

	^ session
]

{ #category : #API }
MTSession class >> forBaselineClass: aBaselineClass selectMethod: methodBlock [

	| methods |
	methods := (aBaselineClass allPackageNames collect: [ :each | 
		            each asPackage ]) flatCollect: [ :each | each methods ].

	^ self compiledMethods: methods thenSelect: methodBlock
]

{ #category : #API }
MTSession class >> forPackages: aCollection selectMethod: methodBlock [

	| methods |
	methods := aCollection asOrderedCollection flatCollect: [ :each | 
		           each methods ].

	^ self compiledMethods: methods thenSelect: methodBlock
]

{ #category : #API }
MTSession class >> initialize [

	forbiddenMethods := Set new
		                    add: MTDecorator >> #run:with:in:;
		                    add: MTSession >> #run:with:in:context:wrapper:;
		                    add:
			                    MTDecorator >> #run:with:in:context:suspended:;
		                    add:
			                    MTDecorator
			                    >> #run:with:in:context:notSuspended:;
		                    addAll:
			                    (MTHandler >> #run:with:in:context:wrapper:)
				                    allImplementations;
		                    addAll:
			                    (MTHandlerPrePostPlugging
			                     >> #run:with:in:preContext:wrapper:)
				                    allImplementations;
		                    addAll: (MTHandlerPrePostPlugging
			                     >>
				                     #run:with:in:postContext:wrapper:carry:return:)
				                    allImplementations;
		                    add:
			                    MTDecorator >> #valueWithReceiver:arguments:;
		                    add: ProtoObject >> #withArgs:executeMethod:;
		                    add:
			                    MTDecorator >> #withSuspendWrapping:context:;
		                    yourself
]

{ #category : #'instance creation' }
MTSession class >> withAll: aCollection [

	^ self compiledMethods: aCollection thenSelect: [ :each | true ]
]

{ #category : #'instance creation' }
MTSession class >> withAllImplementations: aCollection [

	^ self
		  compiledMethods:
		  (aCollection flatCollect: [ :each | each allImplementations ])
		  thenSelect: [ :each | true ]
]

{ #category : #adding }
MTSession >> add: aDecorator [

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
MTSession >> do: aBlock [

	decorators valuesDo: aBlock
]

{ #category : #initialization }
MTSession >> initialize [

	super initialize.

	decorators := Dictionary new.

	stackCounter := 0
]

{ #category : #'as yet unclassified' }
MTSession >> popContext: aContext [

	stackCounter := stackCounter - 1
]

{ #category : #'as yet unclassified' }
MTSession >> pushContext: aContext [

	stackCounter := stackCounter + 1
]

{ #category : #API }
MTSession >> run: aSelector with: anArray in: aReceiver context: aContext wrapper: aWrapper [

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
MTSession >> value: aBlock [

	"Save the current context as 'root' for the following computation."

	home := thisContext.

	^ [ self do: [ :each | each install ] ] value: aBlock then: [ 
		  self do: [ :each | each uninstall ].
		  home := nil ]
]
