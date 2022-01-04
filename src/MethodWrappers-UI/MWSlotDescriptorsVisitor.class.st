Class {
	#name : #MWSlotDescriptorsVisitor,
	#superclass : #CTSlotDescriptorsVisitor,
	#category : #'MethodWrappers-UI'
}

{ #category : #visiting }
MWSlotDescriptorsVisitor >> visitBlockClosure: aBlock [

	^ { (#asString asSlotDescriptor inline: true) }
]
