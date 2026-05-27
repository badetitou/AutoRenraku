Class {
	#name : 'AutoRenrakuStaticGitHubPullRequestClient',
	#superclass : 'Object',
	#instVars : [
		'pullRequest',
		'token'
	],
	#category : 'AutoRenraku-UI-Tests-Fixtures',
	#package : 'AutoRenraku-UI-Tests',
	#tag : 'Fixtures'
}

{ #category : 'accessing' }
AutoRenrakuStaticGitHubPullRequestClient >> pullRequest: aPullRequest [

	pullRequest := aPullRequest
]

{ #category : 'api' }
AutoRenrakuStaticGitHubPullRequestClient >> pullRequest: aNumber repository: aRepository [

	^ pullRequest
]

{ #category : 'accessing' }
AutoRenrakuStaticGitHubPullRequestClient >> token [

	^ token
]

{ #category : 'accessing' }
AutoRenrakuStaticGitHubPullRequestClient >> token: aString [

	token := aString
]
