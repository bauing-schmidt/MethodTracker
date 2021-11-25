"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestMethodWrappers,
	#superclass : #PackageManifest,
	#category : #'MethodWrappers-Manifest'
}

{ #category : #'code-critics' }
ManifestMethodWrappers class >> ruleCollectionProtocolRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#'MWDecoratorCollection class' #compiledMethods:thenSelect: #true)) #'2021-11-25T09:48:34.849466+01:00') )
]
