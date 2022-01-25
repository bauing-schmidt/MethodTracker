"
This is an abstract superclass for proxy objects. It inherits from ProtoObject, which is part of the platform specific layer, but implements most of the proxy functionality.

Instance Variables:
	isInstantiated	<Boolean>	Has this proxy been instantiated or not.
	value	<Object>	What we are proxying for.


"
Class {
	#name : #MTMethodTemperatureAbstractProxy,
	#superclass : #ProtoObject,
	#instVars : [
		'value',
		'isInstantiated'
	],
	#category : #'MethodTracker-Temperature'
}

{ #category : #'instance creation' }
MTMethodTemperatureAbstractProxy class >> new [

	^super new proxyInitialize.
]

{ #category : #'VisualWorks metadata' }
MTMethodTemperatureAbstractProxy class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
MTMethodTemperatureAbstractProxy >> = anObject [
	"In VA we inherit this as identity. Need to override"
	^anObject = self getValue.
]

{ #category : #printing }
MTMethodTemperatureAbstractProxy >> basicPrintOn: aStream [ 
	aStream nextPut: ${.
	isInstantiated 
		ifTrue: [self getValue basicPrintOn: aStream]
		ifFalse: [aStream nextPutAll: 'uninstantiated proxy'].
	aStream nextPut: $}
]

{ #category : #printing }
MTMethodTemperatureAbstractProxy >> basicPrintString [
	| aStream |
	aStream := WriteStream on: String new.
	self basicPrintOn: aStream.
	^aStream contents
]

{ #category : #overrides }
MTMethodTemperatureAbstractProxy >> basicSize [
	^self getValue basicSize.
]

{ #category : #api }
MTMethodTemperatureAbstractProxy >> getValue [

	self subclassesMustImplement
]

{ #category : #notification }
MTMethodTemperatureAbstractProxy >> glorpPostFetch: aSession [
]

{ #category : #notification }
MTMethodTemperatureAbstractProxy >> glorpPostFetchValidate: aSession [
]

{ #category : #accessing }
MTMethodTemperatureAbstractProxy >> glorpRealObject [
	"Return my value.  Ensure instantiation of a proxy:  use #glorpRealObjectIfNone: to avoid forced instantiation.  (On compilers which inline #yourself, that method will not force instantiation despite having the same Smalltalk implementation  as this method;  see also #yourSelf.)
	Functionally, this method need not be implemented here:  were it not, sending it would DNU and so do  'self getValue perform #glorpRealObject', getting Object's implementor.  This method skips that, speeding things trivially."

	^self getValue
]

{ #category : #accessing }
MTMethodTemperatureAbstractProxy >> glorpRealObjectIfNone: aBlock [
	"Return the real object but do NOT force instantiation of a proxy; instead, evaluate the block on the uninstantiated proxy, returning the result."

	^self isInstantiated
		ifTrue: [value]
		ifFalse: [aBlock value]
]

{ #category : #overrides }
MTMethodTemperatureAbstractProxy >> hash [
	^self getValue hash.
]

{ #category : #overrides }
MTMethodTemperatureAbstractProxy >> inspect [
	^self getValue inspect.
]

{ #category : #testing }
MTMethodTemperatureAbstractProxy >> isGlorpProxy [
	^true.
]

{ #category : #overrides }
MTMethodTemperatureAbstractProxy >> isImmutable [
	^self getValue isImmutable.
]

{ #category : #testing }
MTMethodTemperatureAbstractProxy >> isInstantiated [
	isInstantiated isNil ifTrue: [isInstantiated := false].
	^isInstantiated
]

{ #category : #accessing }
MTMethodTemperatureAbstractProxy >> isKindOf: aClass [
	self isInstantiated ifTrue: [^value isKindOf: aClass].
	^false
]

{ #category : #printing }
MTMethodTemperatureAbstractProxy >> printOn: aStream [ 
	aStream nextPut: ${.
	isInstantiated 
		ifTrue: [self getValue printOn: aStream]
		ifFalse: [aStream nextPutAll: 'uninstantiated proxy'].
	aStream nextPut: $}
]

{ #category : #printing }
MTMethodTemperatureAbstractProxy >> printString [

	| aStream |
	aStream := WriteStream on: (String new: 16).
	self printOn: aStream.
	^aStream contents
]

{ #category : #initialize }
MTMethodTemperatureAbstractProxy >> proxyInitialize [

	isInstantiated := false.
]

{ #category : #overrides }
MTMethodTemperatureAbstractProxy >> store [
	"For Object Studio compatibility"
	^self inspectorString.
]

{ #category : #accessing }
MTMethodTemperatureAbstractProxy >> uninstantiate [

	value := nil.
	isInstantiated := false.
]

{ #category : #accessing }
MTMethodTemperatureAbstractProxy >> ~= anObject [ 

	^(self = anObject) not
]
