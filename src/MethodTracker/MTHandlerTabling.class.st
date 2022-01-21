"
I am an abstract decorator that allows my subclasses to use a table (aka Dictionary).
"
Class {
	#name : #MTHandlerTabling,
	#superclass : #MTHandlerDecorating,
	#instVars : [
		'table'
	],
	#category : #MethodTracker
}

{ #category : #initialization }
MTHandlerTabling >> initialize [

	super initialize.

	table := Dictionary new
]
