"
Tests for the GitHub Actions environment adapter used by AutoReneraku.
"
Class {
	#name : 'ARGitHubEnvironmentTest',
	#superclass : 'TestCase',
	#category : 'AutoReneraku-Tests',
	#package : 'AutoReneraku-Tests'
}

{ #category : 'tests' }
ARGitHubEnvironmentTest >> testEmptyGitHubTokenFallsBackToPat [

	| environment |
	environment := ARGitHubEnvironment on: (Dictionary new
			                at: 'GITHUB_TOKEN' put: '';
			                at: 'PAT' put: 'legacy-token';
			                yourself).

	self assert: environment token equals: 'legacy-token'
]

{ #category : 'tests' }
ARGitHubEnvironmentTest >> testGitHubTokenIsPreferredOverPat [

	| environment |
	environment := ARGitHubEnvironment on: (Dictionary new
			                at: 'GITHUB_TOKEN' put: 'github-token';
			                at: 'PAT' put: 'legacy-token';
			                yourself).

	self assert: environment token equals: 'github-token'
]

{ #category : 'tests' }
ARGitHubEnvironmentTest >> testPatTokenIsAcceptedForBackwardCompatibility [

	| environment |
	environment := ARGitHubEnvironment on: (Dictionary new
			                at: 'PAT' put: 'legacy-token';
			                yourself).

	self assert: environment token equals: 'legacy-token'
]

{ #category : 'tests' }
ARGitHubEnvironmentTest >> testProjectNameUsesRepositoryName [

	| environment |
	environment := ARGitHubEnvironment on: (Dictionary new
			                at: 'GITHUB_REPOSITORY' put: 'owner/AutoReneraku';
			                yourself).

	self assert: environment projectName equals: 'AutoReneraku'
]

{ #category : 'tests' }
ARGitHubEnvironmentTest >> testPullRequestCommentsUrlUsesRepositoryAndPullRequestNumber [

	| environment |
	environment := ARGitHubEnvironment on: (Dictionary new
			                at: 'GITHUB_REPOSITORY' put: 'owner/AutoReneraku';
			                at: 'PULL_REQUEST_NUMBER' put: '42';
			                yourself).

	self
		assert: environment pullRequestCommentsUrl
		equals:
		'https://api.github.com/repos/owner/AutoReneraku/pulls/42/comments'
]
