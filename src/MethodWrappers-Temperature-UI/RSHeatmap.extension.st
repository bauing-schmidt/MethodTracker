Extension { #name : #RSHeatmap }

{ #category : #'*MethodWrappers-Temperature-UI' }
RSHeatmap >> show: matrix modelBlock: aBlock [

	| box leftMostShapes topMostShapes boxes |
	self configureScaleFrom: matrix.
	leftMostShapes := OrderedCollection new.
	topMostShapes := OrderedCollection new.
	boxes := OrderedCollection new.
	matrix doWithIndex: [ :row :ic | 
		row doWithIndex: [ :v :ir | 
			| xyModel |
			xyModel := aBlock value: (yLabels at: ic) value: (xLabels at: ir).
			box := RSBox new
				       model: xyModel -> v;
				       size: 40;
				       color: (scale scale: v);
				       addInteraction:
					       (RSPopup text: [ :anAssociation | 
							        anAssociation value asString ]);
				       when: RSMouseLeftClick
				       do: [ :evt | evt shape model key browse ];
				       yourself.
			canvas addShape: box.
			boxes add: box.
			ir = 1 ifTrue: [ leftMostShapes add: box ].
			ic = 1 ifTrue: [ topMostShapes add: box ] ] ].

	RSGridLayout new
		gapSize: 0;
		lineItemsCount: matrix first size;
		on: boxes.

	self setYLabelsOn: leftMostShapes.
	self setXLabelsOn: topMostShapes
]
