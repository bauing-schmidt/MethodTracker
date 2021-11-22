Class {
	#name : #MWHandlerTiming,
	#superclass : #MWHandlerDecorating,
	#instVars : [
		'timing'
	],
	#category : #MethodWrappers
}

{ #category : #evaluation }
MWHandlerTiming >> durationAt: aContext [

	| interval |
	interval := timing at: aContext.

	^ Duration nanoSeconds: interval size * 1000
]

{ #category : #initialization }
MWHandlerTiming >> initialize [

	super initialize.

	timing := IdentityDictionary new
]

{ #category : #hooks }
MWHandlerTiming >> run: aSelector with: anArray in: aReceiver context: aContext carry: anAssoc wrapper: aWrapper [

	^ super
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  context: aContext
		  carry: anAssoc value
		  wrapper: aWrapper
]

{ #category : #evaluation }
MWHandlerTiming >> run: aSelector with: anArray in: aReceiver post: aContext return: anObject carry: anAssoc [

	| now by start |
	now := Time microsecondClockValue.
	start := anAssoc key.
	by := 1.
	now = start ifTrue: [ now := now + by ].

	timing at: aContext put: (start to: now by: by).

	^ super
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  post: aContext
		  return: anObject
		  carry: anAssoc value
]

{ #category : #evaluation }
MWHandlerTiming >> run: aSelector with: anArray in: aReceiver pre: aContext [

	"It is important to keep the given order to properly record timings."

	^ Time microsecondClockValue -> (super
		   run: aSelector
		   with: anArray
		   in: aReceiver
		   pre: aContext)
]
