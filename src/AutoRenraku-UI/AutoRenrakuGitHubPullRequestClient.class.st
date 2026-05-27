"
I fetch GitHub pull request metadata and changed files for the AutoRenraku image UI.
"
Class {
	#name : 'AutoRenrakuGitHubPullRequestClient',
	#superclass : 'Object',
	#instVars : [
		'httpClient',
		'token'
	],
	#category : 'AutoRenraku-UI-GitHub',
	#package : 'AutoRenraku-UI',
	#tag : 'GitHub'
}

{ #category : 'instance creation' }
AutoRenrakuGitHubPullRequestClient class >> withToken: aToken [

	^ self new
		  token: aToken;
		  yourself
]

{ #category : 'private' }
AutoRenrakuGitHubPullRequestClient >> apiUrlForRepository: aRepository path: aPath [

	^ 'https://api.github.com/repos/' , aRepository , aPath
]

{ #category : 'private' }
AutoRenrakuGitHubPullRequestClient >> configureClientForUrl: aUrl [

	| client |
	client := self httpClient.
	client url: aUrl.
	client headerAt: #Accept put: 'application/vnd.github+json'.
	self hasToken ifTrue: [
		client headerAt: #Authorization put: 'token ' , token ].
	^ client
]

{ #category : 'accessing' }
AutoRenrakuGitHubPullRequestClient >> hasToken [

	^ token notNil and: [ token isNotEmpty ]
]

{ #category : 'accessing' }
AutoRenrakuGitHubPullRequestClient >> httpClient [

	^ httpClient ifNil: [ httpClient := ZnClient new ]
]

{ #category : 'accessing' }
AutoRenrakuGitHubPullRequestClient >> httpClient: anObject [

	httpClient := anObject
]

{ #category : 'private' }
AutoRenrakuGitHubPullRequestClient >> jsonAt: aUrl [

	| response |
	response := (self configureClientForUrl: aUrl) get.
	^ response isString
		  ifTrue: [ STONJSON fromString: response ]
		  ifFalse: [ response ]
]

{ #category : 'api' }
AutoRenrakuGitHubPullRequestClient >> pullRequest: aNumber repository: aRepository [

	| pullRequestData changedFiles commentsUrl |
	pullRequestData := self jsonAt: (self
			                    apiUrlForRepository: aRepository
			                    path: '/pulls/' , aNumber asString).
	changedFiles := self
		                pullRequestFiles: aNumber
		                repository: aRepository.
	commentsUrl := pullRequestData at: 'review_comments_url' ifAbsent: [
			               self
				               apiUrlForRepository: aRepository
				               path: '/pulls/' , aNumber asString , '/comments' ].
	^ AutoRenrakuGitHubPullRequest
		  repository: aRepository
		  number: aNumber
		  headSha: ((pullRequestData at: 'head') at: 'sha')
		  changedFiles: changedFiles
		  commentsUrl: commentsUrl
]

{ #category : 'api' }
AutoRenrakuGitHubPullRequestClient >> pullRequestFiles: aNumber repository: aRepository [

	| files page pageFiles |
	files := OrderedCollection new.
	page := 1.
	[
		pageFiles := self jsonAt: (self
				              apiUrlForRepository: aRepository
				              path:
					              '/pulls/' , aNumber asString
					              , '/files?per_page=100&page=' , page asString).
		pageFiles isEmpty ] whileFalse: [
			pageFiles do: [ :each | files add: (each at: 'filename') ].
			page := page + 1 ].
	^ files asArray
]

{ #category : 'accessing' }
AutoRenrakuGitHubPullRequestClient >> token [

	^ token
]

{ #category : 'accessing' }
AutoRenrakuGitHubPullRequestClient >> token: aString [

	token := aString
]
