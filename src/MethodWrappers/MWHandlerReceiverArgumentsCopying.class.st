Class {
	#name : #MWHandlerReceiverArgumentsCopying,
	#superclass : #MWHandlerDecorating,
	#instVars : [
		'table'
	],
	#category : #MethodWrappers
}

{ #category : #adding }
MWHandlerReceiverArgumentsCopying >> addColumnsInPresenter: aPresenter metadata: metadata [

	aPresenter addColumn: (SpStringTableColumn
			 title: 'Return copied'
			 evaluated: [ :aContext | (table at: aContext) return ])
]

{ #category : #initialization }
MWHandlerReceiverArgumentsCopying >> initialize [

	super initialize.

	table := Dictionary new
]

{ #category : #hooks }
MWHandlerReceiverArgumentsCopying >> run: aSelector with: anArray in: aReceiver post: aContext carry: carry return: anObject wrapper: aWrapper [

	aWrapper
		withSuspendWrapping: [ 
			| message |
			message := MessageSent
				           receiver: aReceiver copy
				           selector: aSelector
				           arguments: (anArray collect: [ :each | each copy ]).
			message return: anObject copy.

			table at: aContext put: message ]
		context: aContext.

	^ super
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  post: aContext
		  carry: carry
		  return: anObject
		  wrapper: aWrapper
]
