Class {
	#name : 'AutoRenrakuConfirmingPullRequestReviewPresenter',
	#superclass : 'AutoRenrakuPullRequestReviewPresenter',
	#instVars : [
		'confirmAnswer',
		'confirmRequests'
	],
	#category : 'AutoRenraku-UI-Tests-Fixtures',
	#package : 'AutoRenraku-UI-Tests',
	#tag : 'Fixtures'
}

{ #category : 'accessing' }
AutoRenrakuConfirmingPullRequestReviewPresenter >> confirmAnswer: aBoolean [

	confirmAnswer := aBoolean
]

{ #category : 'private' }
AutoRenrakuConfirmingPullRequestReviewPresenter >> confirmPostWithWarnings: warnings [

	confirmRequests add: warnings.
	^ confirmAnswer
]

{ #category : 'accessing' }
AutoRenrakuConfirmingPullRequestReviewPresenter >> confirmRequests [

	^ confirmRequests asArray
]

{ #category : 'initialization' }
AutoRenrakuConfirmingPullRequestReviewPresenter >> initialize [

	super initialize.
	confirmAnswer := true.
	confirmRequests := OrderedCollection new
]
