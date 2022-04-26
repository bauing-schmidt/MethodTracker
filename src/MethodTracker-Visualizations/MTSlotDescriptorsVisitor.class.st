"
I am a visitor that simplify the representation of blocks.
"
Class {
	#name : #MTSlotDescriptorsVisitor,
	#superclass : #CTSlotDescriptorsVisitor,
	#category : #'MethodTracker-Visualizations'
}

{ #category : #visiting }
MTSlotDescriptorsVisitor >> visitBlockClosure: aBlock [

	^ { (self newSlotDescriptor
		   selector: #asString;
		   inline) }
]
