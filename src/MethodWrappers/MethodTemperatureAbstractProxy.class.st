"
This is an abstract superclass for proxy objects. It inherits from ProtoObject, which is part of the platform specific layer, but implements most of the proxy functionality.

Instance Variables:
	isInstantiated	<Boolean>	Has this proxy been instantiated or not.
	value	<Object>	What we are proxying for.


"
Class {
	#name : #MethodTemperatureAbstractProxy,
	#superclass : #ProtoObject,
	#instVars : [
		'value',
		'isInstantiated'
	],
	#category : #MethodWrappers
}

{ #category : #'instance creation' }
MethodTemperatureAbstractProxy class >> new [

	^super new proxyInitialize.
]

{ #category : #'VisualWorks metadata' }
MethodTemperatureAbstractProxy class >> visualWorksMetadata [

	^ #(
		'namespace' 'Glorp'
	)

]

{ #category : #accessing }
MethodTemperatureAbstractProxy >> = anObject [
	"In VA we inherit this as identity. Need to override"
	^anObject = self getValue.
]

{ #category : #printing }
MethodTemperatureAbstractProxy >> basicPrintOn: aStream [ 
	aStream nextPut: ${.
	isInstantiated 
		ifTrue: [self getValue basicPrintOn: aStream]
		ifFalse: [aStream nextPutAll: 'uninstantiated proxy'].
	aStream nextPut: $}
]

{ #category : #printing }
MethodTemperatureAbstractProxy >> basicPrintString [
	| aStream |
	aStream := WriteStream on: String new.
	self basicPrintOn: aStream.
	^aStream contents
]

{ #category : #overrides }
MethodTemperatureAbstractProxy >> basicSize [
	^self getValue basicSize.
]

{ #category : #api }
MethodTemperatureAbstractProxy >> getValue [

	self subclassesMustImplement
]

{ #category : #notification }
MethodTemperatureAbstractProxy >> glorpPostFetch: aSession [
]

{ #category : #notification }
MethodTemperatureAbstractProxy >> glorpPostFetchValidate: aSession [
]

{ #category : #accessing }
MethodTemperatureAbstractProxy >> glorpRealObject [
	"Return my value.  Ensure instantiation of a proxy:  use #glorpRealObjectIfNone: to avoid forced instantiation.  (On compilers which inline #yourself, that method will not force instantiation despite having the same Smalltalk implementation  as this method;  see also #yourSelf.)
	Functionally, this method need not be implemented here:  were it not, sending it would DNU and so do  'self getValue perform #glorpRealObject', getting Object's implementor.  This method skips that, speeding things trivially."

	^self getValue
]

{ #category : #accessing }
MethodTemperatureAbstractProxy >> glorpRealObjectIfNone: aBlock [
	"Return the real object but do NOT force instantiation of a proxy; instead, evaluate the block on the uninstantiated proxy, returning the result."

	^self isInstantiated
		ifTrue: [value]
		ifFalse: [aBlock value]
]

{ #category : #overrides }
MethodTemperatureAbstractProxy >> hash [
	^self getValue hash.
]

{ #category : #overrides }
MethodTemperatureAbstractProxy >> inspect [
	^self getValue inspect.
]

{ #category : #testing }
MethodTemperatureAbstractProxy >> isGlorpProxy [
	^true.
]

{ #category : #overrides }
MethodTemperatureAbstractProxy >> isImmutable [
	^self getValue isImmutable.
]

{ #category : #testing }
MethodTemperatureAbstractProxy >> isInstantiated [
	isInstantiated isNil ifTrue: [isInstantiated := false].
	^isInstantiated
]

{ #category : #accessing }
MethodTemperatureAbstractProxy >> isKindOf: aClass [
	self isInstantiated ifTrue: [^value isKindOf: aClass].
	^false
]

{ #category : #printing }
MethodTemperatureAbstractProxy >> printOn: aStream [ 
	aStream nextPut: ${.
	isInstantiated 
		ifTrue: [self getValue printOn: aStream]
		ifFalse: [aStream nextPutAll: 'uninstantiated proxy'].
	aStream nextPut: $}
]

{ #category : #printing }
MethodTemperatureAbstractProxy >> printString [

	| aStream |
	aStream := WriteStream on: (String new: 16).
	self printOn: aStream.
	^aStream contents
]

{ #category : #initialize }
MethodTemperatureAbstractProxy >> proxyInitialize [

	isInstantiated := false.
]

{ #category : #overrides }
MethodTemperatureAbstractProxy >> store [
	"For Object Studio compatibility"
	^self inspectorString.
]

{ #category : #accessing }
MethodTemperatureAbstractProxy >> uninstantiate [

	value := nil.
	isInstantiated := false.
]

{ #category : #accessing }
MethodTemperatureAbstractProxy >> ~= anObject [ 

	^(self = anObject) not
]
