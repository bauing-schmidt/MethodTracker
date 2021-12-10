Extension { #name : #Context }

{ #category : #'*MethodWrappers' }
Context >> asContextReifiedFromWrapping [

	| recv |
	recv := self arguments third.

	^ self class
		  sender: sender
		  receiver: recv
		  method: (recv class lookupSelector: self arguments first)
		  arguments: self arguments second
]
