"
I am a variant that waits a delay before returning from the hook notification message.
"
Class {
	#name : #MWHandlerProfiling,
	#superclass : #MWHandler,
	#instVars : [
		'callsLog',
		'tree',
		'tick',
		'table'
	],
	#category : #MethodWrappers
}

{ #category : #evaluation }
MWHandlerProfiling >> at: aKey ifAbsent: aBlock [

	^ table at: aKey ifAbsent: aBlock
]

{ #category : #'as yet unclassified' }
MWHandlerProfiling >> callsLog [

	^ callsLog select: [ :anAssocOrLookupKey | 
		  anAssocOrLookupKey isAssociation and: [ 
			  | messageSend |
			  messageSend := anAssocOrLookupKey value.
			  messageSend selector = method selector and: [ 
				  messageSend receiver isKindOf: method methodClass ] ] ]
]

{ #category : #initialization }
MWHandlerProfiling >> initialize [

	super initialize.

	callsLog := OrderedCollection new.
	tick := 0.
	table := IdentityDictionary new
]

{ #category : #evaluation }
MWHandlerProfiling >> run: aSelector with: anArray in: aReceiver post: aContext return: anObject carry: anAssoc [

	| logicalDuration timespan returnTimespan index |
	timespan := anAssoc key.

	[ 
	logicalDuration := 0.
	index := callsLog size ]
		for: [ index > 0 ]
		collect: [ callsLog at: index ]
		do: [ :break :each | 
			| v |
			v := each value
				     ifMessageSend: [ 1 ]
				     ifReturnMessageSend: [ :aMessageSend | 
				     aMessageSend ifSelfSend: [ 1 ] ifNotSelfSend: [ 0 ] ].

			logicalDuration := logicalDuration + v.

			each == anAssoc ifTrue: break ]
		then: [ index := index - 1 ].

	anAssoc value in: [ :fullMessageSend | 
		| returnMessageSend |
		returnMessageSend := fullMessageSend asReturnMessageSend
			                     return: anObject;
			                     yourself.
		fullMessageSend
			ifSelfSend: [ 
				anAssoc value: returnMessageSend.
				returnTimespan := nil ]
			ifNotSelfSend: [ 
				returnTimespan := TimespanDiscrete new.
				callsLog add: returnTimespan -> returnMessageSend ] ].

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
MWHandlerProfiling >> run: aSelector with: anArray in: aReceiver pre: aContext [

	| messageSend span anAssoc parentContext |
	super
		run: aSelector
		with: anArray
		in: aReceiver
		pre: aContext.

	parentContext := aContext sender sender sender sender.

	tree parent: parentContext child: aContext.

	messageSend := (RSFullMessageSend
		                receiver: aReceiver
		                selector: aSelector
		                arguments: anArray)
		               client: aContext client;
		               callerSelector: aContext sender selector;
		               yourself.

	span := TimespanDiscrete new
		        start: DateAndTime now;
		        duration: nil;
		        logicalStart: tick;
		        logicalDuration: nil;
		        yourself.

	tick := tick + 1.

	anAssoc := span -> messageSend.

	callsLog add: anAssoc.

	table at: aContext put: anAssoc.

	"The following object will be received in the post run message."
	^ anAssoc
]

{ #category : #accessing }
MWHandlerProfiling >> tree: aTree [

	tree := aTree
]
