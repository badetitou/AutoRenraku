Class {
	#name : 'AutoRenrakuPullRequestReviewPresenterTest',
	#superclass : 'TestCase',
	#instVars : [
		'presenter'
	],
	#category : 'AutoRenraku-UI-Tests-Tests',
	#package : 'AutoRenraku-UI-Tests',
	#tag : 'Tests'
}

{ #category : 'fixtures' }
AutoRenrakuPullRequestReviewPresenterTest >> pullRequestForLoadedFixture [

	^ AutoRenrakuGitHubPullRequest
		  repository: 'owner/AutoReneraku'
		  number: 42
		  headSha: self pullRequestHeadSha
		  changedFiles:
		  #( 'src/AutoReneraku-Tests/AutoRenerakuTestSample.class.st' )
		  commentsUrl:
		  'https://api.github.com/repos/owner/AutoReneraku/pulls/42/comments'
]

{ #category : 'fixtures' }
AutoRenrakuPullRequestReviewPresenterTest >> pullRequestHeadSha [

	^ IceRepository registry
		  detect: [ :each | each name = 'AutoReneraku' ]
		  ifFound: [ :repository | repository headCommit id ]
		  ifNone: [ 'abc123' ]
]

{ #category : 'fixtures' }
AutoRenrakuPullRequestReviewPresenterTest >> pullRequestWithAlignmentWarning [

	^ AutoRenrakuGitHubPullRequest
		  repository: 'owner/AutoReneraku'
		  number: 42
		  headSha: 'definitely-not-the-loaded-head'
		  changedFiles:
		  #( 'src/AutoReneraku-Tests/AutoRenerakuTestSample.class.st' )
		  commentsUrl:
		  'https://api.github.com/repos/owner/AutoReneraku/pulls/42/comments'
]

{ #category : 'fixtures' }
AutoRenrakuPullRequestReviewPresenterTest >> pullRequestWithMissingClass [

	^ AutoRenrakuGitHubPullRequest
		  repository: 'owner/AutoReneraku'
		  number: 42
		  headSha: self pullRequestHeadSha
		  changedFiles: #( 'src/AutoReneraku-Tests/MissingClass.class.st' )
		  commentsUrl:
		  'https://api.github.com/repos/owner/AutoReneraku/pulls/42/comments'
]

{ #category : 'running' }
AutoRenrakuPullRequestReviewPresenterTest >> setUp [

	super setUp.
	AutoRenerakuTest new installFixtureMethods.
	presenter := AutoRenrakuConfirmingPullRequestReviewPresenter new.
	presenter client: AutoRenrakuStaticGitHubPullRequestClient new
]

{ #category : 'running' }
AutoRenrakuPullRequestReviewPresenterTest >> tearDown [

	[ AutoRenerakuTest new installFixtureMethods ] ensure: [
		super tearDown ]
]

{ #category : 'tests' }
AutoRenrakuPullRequestReviewPresenterTest >> testDryRunBuildsSuggestionsWithoutPosting [

	| result fakeClient |
	fakeClient := presenter client.
	fakeClient pullRequest: self pullRequestForLoadedFixture.

	result := presenter
		          runDryPullRequestNumber: 42
		          repository: 'owner/AutoReneraku'
		          token: ''.

	self assert: fakeClient token isEmpty.
	self assert: result builtSuggestions isNotEmpty.
	self assert: result postedSuggestions isEmpty.
	self assert: result erroredMethods isEmpty
]

{ #category : 'tests' }
AutoRenrakuPullRequestReviewPresenterTest >> testMissingChangedClassProducesWarning [

	| result fakeClient |
	fakeClient := presenter client.
	fakeClient pullRequest: self pullRequestWithMissingClass.

	result := presenter
		          runDryPullRequestNumber: 42
		          repository: 'owner/AutoReneraku'
		          token: ''.

	self assert: result hasWarnings.
	self assert: (result warnings anySatisfy: [ :warning |
			 warning includesSubstring: 'MissingClass' ])
]

{ #category : 'tests' }
AutoRenrakuPullRequestReviewPresenterTest >> testPostCommentsRequestsConfirmationWhenWarningsExist [

	| result fakeClient |
	fakeClient := presenter client.
	fakeClient pullRequest: self pullRequestWithAlignmentWarning.
	presenter confirmAnswer: false.

	result := presenter
		          postPullRequestNumber: 42
		          repository: 'owner/AutoReneraku'
		          token: 'secret'.

	self assert: presenter confirmRequests size equals: 1.
	self assert: result hasWarnings.
	self assert: result postedSuggestions isEmpty.
	self assert: result builtSuggestions isEmpty
]

{ #category : 'tests' }
AutoRenrakuPullRequestReviewPresenterTest >> testPostCommentsRequiresToken [

	| result |
	result := presenter
		          postPullRequestNumber: 42
		          repository: 'owner/AutoReneraku'
		          token: ''.

	self assert: result postedSuggestions isEmpty.
	self assert: result hasWarnings.
	self
		assert: result warnings first
		equals: 'A GitHub token is required to post AutoRenraku comments.'
]

{ #category : 'tests' }
AutoRenrakuPullRequestReviewPresenterTest >> testResultTextContainsSuggestionAndWarningCounts [

	| result text |
	result := ARReviewRunResult new.
	result recordWarning: 'Careful'.
	result
		recordCorrectedMethod: AutoRenerakuTestSample >> #testOutside
		suggestion: (Dictionary new
				 at: #path put: 'src/Pkg/Class.class.st';
				 at: #line put: 12;
				 yourself).

	text := presenter resultTextFor: result.

	self assert: (text includesSubstring: 'Built suggestions: 1').
	self assert:
		(text includesSubstring: 'src/Pkg/Class.class.st line 12')
]
