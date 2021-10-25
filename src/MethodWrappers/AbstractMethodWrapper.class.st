"
I am an abstract class that install a wrapper around a compiled method, and uninstall it when finished my scope.
"
Class {
	#name : #AbstractMethodWrapper,
	#superclass : #ProtoObject,
	#instVars : [
		'method',
		'enabled',
		'installed',
		'callsLog',
		'random'
	],
	#category : #MethodWrappers
}

{ #category : #API }
AbstractMethodWrapper class >> forBaselineClass: aBaselineClass selectMethod: methodBlock [
	
	| methods |
	methods := (aBaselineClass allPackageNames collect: [ :each | 
		            each asPackage ]) flatCollect: [ :each | each methods ].
	
	^ self forMethods: methods selectMethod: methodBlock
]

{ #category : #API }
AbstractMethodWrapper class >> forMethods: aCollection selectMethod: methodBlock [

	| methods excludingClasses |
	excludingClasses := (AbstractMethodWrapper withAllSubclasses
	                     , AbstractProxy withAllSubclasses) asSet.

	methods := aCollection select: [ :aMethod | 
		           (excludingClasses includes: aMethod methodClass) not 
			           and: [ methodBlock value: aMethod ] ].

	^ methods collect: [ :each | self on: each ]
]

{ #category : #API }
AbstractMethodWrapper class >> forPackages: aCollection selectMethod: methodBlock [
	
	| methods |
	methods := aCollection asOrderedCollection flatCollect: [ :each | each methods ].
	
	^ self forMethods: methods selectMethod: methodBlock
]

{ #category : #'instance creation' }
AbstractMethodWrapper class >> on: aMethodReference [

	^ self new initializeOn: aMethodReference
]

{ #category : #initialization }
AbstractMethodWrapper class >> reset [

	<script>
	self allSubclassesDo: [ :each | 
		each allInstances do: [ :w | 
			[ w uninstall ] onDNU: #uninstall do: [  ] ] ].
	SpNullApplication reset.
	Smalltalk garbageCollect
]

{ #category : #accessing }
AbstractMethodWrapper >> callsLog [

	^ callsLog
]

{ #category : #actions }
AbstractMethodWrapper >> disable [

	enabled := false
]

{ #category : #private }
AbstractMethodWrapper >> doesNotUnderstand: aMessage [

	^ method perform: aMessage selector withArguments: aMessage arguments
]

{ #category : #actions }
AbstractMethodWrapper >> enable [

	enabled := true
]

{ #category : #initialization }
AbstractMethodWrapper >> initializeOn: aMethodReference [

	  aMethodReference == aMethodReference compiledMethod
		  ifTrue: [ 
			  method := aMethodReference.
			  installed := false.
			  enabled := false.
			  random := RandomGaussian seed: 17.
			  callsLog := OrderedCollection new ]
		  ifFalse: [ Error signal ]
]

{ #category : #actions }
AbstractMethodWrapper >> install [

	installed
		ifTrue: [ Error signal ]
		ifFalse: [ method installWrapper: self ]
]

{ #category : #dispatched }
AbstractMethodWrapper >> installCompiledMethod: aCompiledMethod [

	method == aCompiledMethod
		ifTrue: [ 
			method methodClass methodDict at: method selector put: self.
			installed := true ]
		ifFalse: [ Error signal ]
]

{ #category : #dispatched }
AbstractMethodWrapper >> installWrapper: aWrapper [

	Warning signal: 'Attempting to wrap a wrapper'
]

{ #category : #accessing }
AbstractMethodWrapper >> method [
	^ method
]

{ #category : #evaluation }
AbstractMethodWrapper >> noticeExecutionWith: anArray in: aReceiver [

	super subclassResponsibility
]

{ #category : #evaluation }
AbstractMethodWrapper >> run: aSelector with: anArray in: aReceiver [

	        | anAssoc result |
	        aSelector == method selector ifFalse: [ Error signal ].

	        enabled
		        ifTrue: [ 
			        | messageSend |
			        messageSend := (RSFullMessageSend
				                        receiver: aReceiver
				                        selector: method selector
				                        arguments: anArray)
				                       client: thisContext client;
				                       callerSelector: thisContext sender selector;
				                       yourself.

			        anAssoc := self timeKey -> messageSend.

			        callsLog add: anAssoc.

			        self noticeExecutionWith: anArray in: aReceiver ]
		        ifFalse: [ anAssoc := nil ].

	        result := aReceiver withArgs: anArray executeMethod: method.

	        anAssoc ifNotNil: [ 
		        | duration |
		        duration := DateAndTime now
		                    - (self startingOfTimeKey: anAssoc key) max:
			                    (Duration milliSeconds: 1).

		        self timeKey: anAssoc key duration: duration ].

	        ^ result
]

{ #category : #evaluation }
AbstractMethodWrapper >> startingOfTimeKey: aTimespan [

	  ^ aTimespan start
]

{ #category : #evaluation }
AbstractMethodWrapper >> timeKey [

	  ^ Timespan starting: DateAndTime now duration: nil
]

{ #category : #evaluation }
AbstractMethodWrapper >> timeKey: aTimeStan duration: duration [

	  aTimeStan duration: duration
]

{ #category : #actions }
AbstractMethodWrapper >> uninstall [

	installed
		ifTrue: [ 
			method methodClass methodDict at: method selector put: method.
			installed := false ]
		ifFalse: [ "Warning signal" ]
]
