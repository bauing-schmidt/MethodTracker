"
I am a variant that waits a delay before returning from the hook notification message.
"
Class {
	#name : #DelayMethodTemperatureWrapper,
	#superclass : #MethodTemperatureWrapper,
	#classVars : [
		'callsLog',
		'mutex',
		'tick'
	],
	#category : #'MethodWrappers-Temperature'
}

{ #category : #'as yet unclassified' }
DelayMethodTemperatureWrapper class >> callsLog [

	          ^ callsLog copy
]

{ #category : #initialization }
DelayMethodTemperatureWrapper class >> initialize [

	  self tick: 0
]

{ #category : #'as yet unclassified' }
DelayMethodTemperatureWrapper class >> tick: aNumber [

	          tick := aNumber.
	          mutex := Semaphore forMutualExclusion.
	          callsLog := OrderedCollection new
]

{ #category : #'as yet unclassified' }
DelayMethodTemperatureWrapper >> callsLog [

	^ callsLog select: [ :anAssocOrLookupKey | 
		  anAssocOrLookupKey isAssociation and: [ 
			  | messageSend |
			  messageSend := anAssocOrLookupKey value.
			  messageSend selector = method selector and: [ 
				  messageSend receiver isKindOf: method methodClass ] ] ]
]

{ #category : #evaluation }
DelayMethodTemperatureWrapper >> run: aSelector with: anArray in: aReceiver post: aContext return: anObject carry: anAssoc [

	| logicalDuration timespan returnTimespan |
	timespan := anAssoc key.

	mutex critical: [ 
		| index |
		[ 
		logicalDuration := 0.
		index := callsLog size ]
			for: [ index > 0 ]
			collect: [ callsLog at: index ]
			do: [ :break :each | 
				each value
					ifMessageSend: [ logicalDuration := logicalDuration + 1 ]
					ifReturnMessageSend: [ :aMessageSend |  ].

				each == anAssoc ifTrue: break ]
			then: [ index := index - 1 ].

		anAssoc value
			ifSelfSend: [ returnTimespan := nil ]
			ifNotSelfSend: [ 
				returnTimespan := LogicalTimespan new.

				callsLog add: returnTimespan -> anAssoc value asReturnMessageSend ] ].

	timespan
		duration: DateAndTime now - timespan start;
		logicalDuration: logicalDuration.

	returnTimespan ifNotNil: [ 
		returnTimespan
			start: timespan end;
			duration: Duration zero;
			logicalStart: timespan logicalStart;
			logicalDuration: timespan logicalDuration ]
]

{ #category : #evaluation }
DelayMethodTemperatureWrapper >> run: aSelector with: anArray in: aReceiver pre: aContext [

	| messageSend |
	super
		run: aSelector
		with: anArray
		in: aReceiver
		pre: aContext.

	messageSend := (RSFullMessageSend
		                receiver: aReceiver
		                selector: aSelector
		                arguments: anArray)
		               client: aContext client;
		               callerSelector: aContext sender selector;
		               yourself.

	^ mutex critical: [ 
		  | span anAssoc |
		  span := LogicalTimespan new
			          start: DateAndTime now;
			          duration: nil;
			          logicalStart: tick;
			          logicalDuration: nil;
			          yourself.

		  tick := tick + 1.

		  anAssoc := span -> messageSend.

		  callsLog add: anAssoc.

		  "The following object will be received in the post run message."
		  anAssoc ]
]
