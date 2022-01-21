Class {
	#name : #MTSession,
	#superclass : #Object,
	#instVars : [
		'stackCounter',
		'trackers',
		'home'
	],
	#classVars : [
		'forbiddenMethods'
	],
	#category : #MethodTracker
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
		decorator := MTTracker new
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
		                    add: MTTracker >> #run:with:in:;
		                    add: MTSession >> #run:with:in:context:tracker:;
		                    add:
			                    MTTracker >> #run:with:in:context:suspended:;
		                    add:
			                    MTTracker >> #run:with:in:context:notSuspended:;
		                    addAll:
			                    (MTHandler >> #run:with:in:context:tracker:)
				                    allImplementations;
		                    addAll:
			                    (MTHandlerPrePostPlugging
			                     >> #run:with:in:preContext:tracker:)
				                    allImplementations;
		                    addAll: (MTHandlerPrePostPlugging
			                     >>
				                     #run:with:in:postContext:tracker:carry:return:)
				                    allImplementations;
		                    add: MTTracker >> #valueWithReceiver:arguments:;
		                    add: ProtoObject >> #withArgs:executeMethod:;
		                    add: MTTracker >> #withSuspendWrapping:context:;
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
MTSession >> add: aTracker [

	| compiledMethod |
	compiledMethod := aTracker compiledMethod.

	^ (forbiddenMethods includes: compiledMethod)
		  ifTrue: [ Object new ]
		  ifFalse: [ 
			  trackers at: compiledMethod ifAbsentPut: [ 
				  aTracker
					  session: self;
					  yourself ] ]
]

{ #category : #'*MethodWrappers' }
MTSession >> do: aBlock [

	trackers valuesDo: aBlock
]

{ #category : #initialization }
MTSession >> initialize [

	super initialize.

	trackers := Dictionary new.

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
MTSession >> run: aSelector with: anArray in: aReceiver context: aContext tracker: aTracker [

	^ (stackCounter = 0 and: [ aContext hasSender: home ])
		  ifTrue: [ 
			  aTracker
				  run: aSelector
				  with: anArray
				  in: aReceiver
				  context: aContext
				  notSuspended: true ]
		  ifFalse: [ 
			  aTracker
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

	^ [ 
	  self do: [ :each | each install ].
	  aBlock value ] ensure: [ 
		  self do: [ :each | each uninstall ].
		  home := nil ]
]
