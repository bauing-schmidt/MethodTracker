Extension { #name : #SpCodePresenter }

{ #category : #'*MethodTracker-UI' }
SpCodePresenter >> evaluateCompiledMethod [

	^ [ 
	  | receiver |
	  receiver := self interactionModel doItReceiver.
	  BlockClosure compiler
		  source: self text readStream;
		  context: self interactionModel doItContext;
		  receiver: self interactionModel doItReceiver;
		  requestor: self interactionModel;
		  failBlock: [ nil ];
		  evaluate ]
		  on: Error
		  do: [ nil ]
]
