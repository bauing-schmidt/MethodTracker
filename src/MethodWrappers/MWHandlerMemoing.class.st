Class {
	#name : #MWHandlerMemoing,
	#superclass : #MWHandler,
	#instVars : [
		'table',
		'handler'
	],
	#category : #MethodWrappers
}

{ #category : #accessing }
MWHandlerMemoing >> handler: aHandler [

	handler := aHandler
]

{ #category : #'as yet unclassified' }
MWHandlerMemoing >> initialize [

	super initialize.

	table := Dictionary new
]

{ #category : #'as yet unclassified' }
MWHandlerMemoing >> run: aSelector with: anArray in: aReceiver context: aContext carry: carry wrapper: aWrapper [

	^ table
		  at: { 
				  aSelector.
				  aReceiver } , anArray
		  ifAbsentPut: [ 
			  handler
				  run: aSelector
				  with: anArray
				  in: aReceiver
				  context: aContext
				  carry: carry
				  wrapper: aWrapper ]
]

{ #category : #evaluation }
MWHandlerMemoing >> run: aSelector with: anArray in: aReceiver post: aContext return: anObject carry: carry [

	^ handler
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  post: aContext
		  return: anObject
		  carry: carry
]

{ #category : #evaluation }
MWHandlerMemoing >> run: aSelector with: anArray in: aReceiver pre: aContext [

	^ handler
		  run: aSelector
		  with: anArray
		  in: aReceiver
		  pre: aContext
]
