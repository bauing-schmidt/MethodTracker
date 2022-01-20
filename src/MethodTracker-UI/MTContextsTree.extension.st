Extension { #name : #MTContextsTree }

{ #category : #'*MethodTracker-UI' }
MTContextsTree >> asShapeUMLSequenceDiagram: aBuilder metadata: metadata [

	| timedMessageSends objectsSeenSoFar |
	timedMessageSends := OrderedCollection new.
	objectsSeenSoFar := IdentityDictionary new.

	"Preprocessing to create the sequence of message sends."
	self
		pre: [ :each | 
			| currentParent recv client reifiedContext reifiedParentContext timedMessageSend model timespan |
			"Retrive the parent of the `each` context, it is mandatory to have it."
			currentParent := self parent: each ifAbsent: [ Error signal ].

			"Reify the context but ignoring the metadata info because we want to draw
			 the skeleton of the real objects that are involved and not their clones."
			reifiedContext := each asArgumentsReifiedContext.
			reifiedParentContext := currentParent asArgumentsReifiedContext.

			client := reifiedParentContext receiver.
			recv := reifiedContext receiver.

			"Mark both `recv` and `client` as seen in order to stick an alias in the interpolation.
			 The order in which client and recv are inserted matters."
			objectsSeenSoFar
				ifAbsentPutOrderAt: client;
				ifAbsentPutOrderAt: recv.

			"Final addition of this entry."
			model := metadata at: each.

			timespan := TimespanDiscrete new
				            start: model startTime asDateAndTime;
				            duration: model duration;
				            logicalStart: model visit x;
				            logicalDuration: model visitDuration;
				            yourself.

			timedMessageSend := MTTimedMessageSend new
				                    timespan: timespan;
				                    messageSend: ((RSFullMessageSend
						                      receiver: recv
						                      selector: reifiedContext selector
						                      arguments: model reifiedContext arguments)
						                     client: client;
						                     callerSelector:
							                     reifiedParentContext selector;
						                     yourself);
				                    yourself.

			timedMessageSends add: timedMessageSend.

			"Such association is then passed in the `post:` block as second argument."
			timedMessageSend ]
		post: [ :each :timedMessageSend | 
			| timespan returnTimespan returnTimedMessageSend |
			timespan := timedMessageSend timespan.

			returnTimespan := TimespanDiscrete new
				                  start: timespan end;
				                  duration: Duration zero;
				                  logicalStart: timespan logicalStart;
				                  logicalDuration: timespan logicalDuration;
				                  yourself.

			returnTimedMessageSend := MTTimedMessageSend new
				                          timespan: returnTimespan;
				                          messageSend:
					                          (timedMessageSend messageSend
						                           asReturnMessageSend
						                           return: (metadata at: each) return;
						                           yourself);
				                          yourself.

			timedMessageSends add: returnTimedMessageSend ].

	aBuilder
		objectsSeenSoFar: objectsSeenSoFar;
		messagesSends: timedMessageSends;
		build.

	^ aBuilder canvas asShape
]
