Class {
	#name : 'AutoRenrakuGitHubPullRequestClientTest',
	#superclass : 'TestCase',
	#instVars : [
		'client',
		'httpClient'
	],
	#category : 'AutoRenraku-UI-Tests-Tests',
	#package : 'AutoRenraku-UI-Tests',
	#tag : 'Tests'
}

{ #category : 'fixtures' }
AutoRenrakuGitHubPullRequestClientTest >> filesUrlForPage: anInteger [

	^ 'https://api.github.com/repos/owner/repository/pulls/42/files?per_page=100&page='
	  , anInteger asString
]

{ #category : 'fixtures' }
AutoRenrakuGitHubPullRequestClientTest >> pullRequestUrl [

	^ 'https://api.github.com/repos/owner/repository/pulls/42'
]

{ #category : 'running' }
AutoRenrakuGitHubPullRequestClientTest >> setUp [

	super setUp.
	httpClient := AutoRenrakuFakeGitHubHTTPClient new.
	client := AutoRenrakuGitHubPullRequestClient new.
	client httpClient: httpClient
]

{ #category : 'tests' }
AutoRenrakuGitHubPullRequestClientTest >> testAuthorizationHeaderIsNotSentWhenTokenIsMissing [

	httpClient responseAt: (self filesUrlForPage: 1) put: '[]'.

	client pullRequestFiles: 42 repository: 'owner/repository'.

	self assert: (httpClient headerAt: #Authorization) isNil
]

{ #category : 'tests' }
AutoRenrakuGitHubPullRequestClientTest >> testAuthorizationHeaderIsSentWhenTokenIsPresent [

	client token: 'secret-token'.
	httpClient responseAt: (self filesUrlForPage: 1) put: '[]'.

	client pullRequestFiles: 42 repository: 'owner/repository'.

	self
		assert: (httpClient headerAt: #Authorization)
		equals: 'token secret-token'
]

{ #category : 'tests' }
AutoRenrakuGitHubPullRequestClientTest >> testPullRequestFallsBackToReviewCommentsEndpoint [

	| pullRequest |
	httpClient
		responseAt: self pullRequestUrl
		put:
		'{"head":{"sha":"abc123"},"comments_url":"https://api.github.com/repos/owner/repository/issues/42/comments"}'.
	httpClient responseAt: (self filesUrlForPage: 1) put: '[]'.

	pullRequest := client pullRequest: 42 repository: 'owner/repository'.

	self
		assert: pullRequest commentsUrl
		equals:
		'https://api.github.com/repos/owner/repository/pulls/42/comments'
]

{ #category : 'tests' }
AutoRenrakuGitHubPullRequestClientTest >> testPullRequestFilesUsesPagination [

	| files |
	httpClient
		responseAt: (self filesUrlForPage: 1)
		put: '[{"filename":"one.class.st"}]'.
	httpClient
		responseAt: (self filesUrlForPage: 2)
		put: '[{"filename":"two.class.st"}]'.
	httpClient responseAt: (self filesUrlForPage: 3) put: '[]'.

	files := client pullRequestFiles: 42 repository: 'owner/repository'.

	self assert: files equals: #( 'one.class.st' 'two.class.st' ).
	self assert: httpClient requestedUrls size equals: 3
]

{ #category : 'tests' }
AutoRenrakuGitHubPullRequestClientTest >> testPullRequestParsesHeadShaCommentsUrlAndFiles [

	| pullRequest |
	httpClient
		responseAt: self pullRequestUrl
		put:
		'{"head":{"sha":"abc123"},"comments_url":"https://api.github.com/repos/owner/repository/issues/42/comments","review_comments_url":"https://api.github.com/repos/owner/repository/pulls/42/comments"}'.
	httpClient
		responseAt: (self filesUrlForPage: 1)
		put:
		'[{"filename":"src/Package/Class.class.st"},{"filename":"README.md"}]'.
	httpClient responseAt: (self filesUrlForPage: 2) put: '[]'.

	pullRequest := client pullRequest: 42 repository: 'owner/repository'.

	self assert: pullRequest repository equals: 'owner/repository'.
	self assert: pullRequest repositoryName equals: 'repository'.
	self assert: pullRequest number equals: 42.
	self assert: pullRequest headSha equals: 'abc123'.
	self
		assert: pullRequest commentsUrl
		equals:
		'https://api.github.com/repos/owner/repository/pulls/42/comments'.
	self
		assert: pullRequest changedFiles
		equals: #( 'src/Package/Class.class.st' 'README.md' )
]
