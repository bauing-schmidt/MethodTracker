Class {
	#name : #MTSlotDescriptorsVisitor,
	#superclass : #CTSlotDescriptorsVisitor,
	#category : #'MethodTracker-UI'
}

{ #category : #visiting }
MTSlotDescriptorsVisitor >> visitBlockClosure: aBlock [

	^ { (#asString asSlotDescriptor inline: true) }
]
