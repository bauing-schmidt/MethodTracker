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
