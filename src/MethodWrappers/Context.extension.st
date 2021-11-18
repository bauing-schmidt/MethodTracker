Extension { #name : #Context }

{ #category : #'*MethodWrappers' }
Context >> findContextSuchThatReceiverIsntWrapping [

	| parentContext |
	parentContext := self.

	[ 
	| home recv |
	home := parentContext home.

	parentContext := parentContext == home
		                 ifTrue: [ parentContext sender ]
		                 ifFalse: [ home ].

	recv := parentContext receiver.

	(recv isKindOf: MWBehavior) or: [ recv isKindOf: MWHandler ] ]
		whileTrue.

	^ parentContext
]
