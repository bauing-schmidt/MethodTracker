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
		'table',
		'returns'
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
	table := IdentityDictionary new.
	returns := IdentityDictionary new
]

{ #category : #evaluation }
MWHandlerProfiling >> returnAt: aKey ifAbsent: aBlock [

	^ returns at: aKey ifAbsent: aBlock
]

{ #category : #evaluation }
MWHandlerProfiling >> run: aSelector with: anArray in: aReceiver post: aContext return: anObject carry: carry [

	returns at: aContext put: anObject.

	^ super
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  post: aContext
		  return: anObject
		  carry: carry
]

{ #category : #evaluation }
MWHandlerProfiling >> run: aSelector with: anArray in: aReceiver pre: aContext [

	| messageSend span anAssoc |
	super
		run: aSelector
		with: anArray
		in: aReceiver
		pre: aContext.

	(aContext sender findContextSuchThat: [ :ctx | 
		 ctx selector = #run:with:in: and: [ ctx receiver isMethodWrapper ] ])
		ifNil: [ tree parent: aContext child: aContext ]
		ifNotNil: [ :parentContext | 
		tree parent: parentContext child: aContext ].

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
