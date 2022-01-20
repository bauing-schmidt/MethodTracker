Class {
	#name : #MTSlotDescriptorsVisitor,
	#superclass : #CTSlotDescriptorsVisitor,
	#category : #'MethodWrappers-UI'
}

{ #category : #visiting }
MTSlotDescriptorsVisitor >> visitBlockClosure: aBlock [

	^ { (#asString asSlotDescriptor inline: true) }
]
