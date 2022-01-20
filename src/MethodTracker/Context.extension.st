Extension { #name : #Context }

{ #category : #'*MethodTracker' }
Context >> asArgumentsReifiedContext [

	| recv arguments |
	arguments := self arguments.
	recv := arguments third.

	^ self class
		  sender: sender
		  receiver: recv
		  method: (recv class lookupSelector: arguments first)
		  arguments: arguments second
]
