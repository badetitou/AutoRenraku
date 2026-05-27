Extension { #name : 'AutoReneraku' }

{ #category : '*AutoRenraku-UI' }
AutoReneraku class >> dryRunPullRequest: aNumber repository: aRepository [

	^ self dryRunPullRequest: aNumber repository: aRepository token: ''
]

{ #category : '*AutoRenraku-UI' }
AutoReneraku class >> dryRunPullRequest: aNumber repository: aRepository token: aToken [

	^ AutoRenrakuPullRequestReviewPresenter new
		  runDryPullRequestNumber: aNumber
		  repository: aRepository
		  token: aToken
]
