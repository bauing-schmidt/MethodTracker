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

	returns := IdentityDictionary new
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

	(aContext sender findContextSuchThat: [ :ctx | 
		 ctx selector = #run:with:in: and: [ ctx receiver isMethodWrapper ] ])
		ifNil: [ tree parent: aContext child: aContext ]
		ifNotNil: [ :parentContext | 
		tree parent: parentContext child: aContext ].

	^ super
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  pre: aContext
]

{ #category : #accessing }
MWHandlerProfiling >> tree: aTree [

	tree := aTree
]
