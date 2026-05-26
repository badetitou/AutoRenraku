"
I expose the GitHub Actions environment values needed by AutoReneraku.
"
Class {
	#name : 'ARGitHubEnvironment',
	#superclass : 'Object',
	#instVars : [
		'variables'
	],
	#category : 'AutoReneraku',
	#package : 'AutoReneraku'
}

{ #category : 'instance creation' }
ARGitHubEnvironment class >> current [

	^ self on: Smalltalk os environment
]

{ #category : 'instance creation' }
ARGitHubEnvironment class >> on: anEnvironment [

	^ self new
		  variables: anEnvironment;
		  yourself
]

{ #category : 'accessing' }
ARGitHubEnvironment >> commitSha [

	^ self requiredAt: 'COMMIT_SHA'
]

{ #category : 'accessing' }
ARGitHubEnvironment >> projectName [

	^ self repositoryName
]

{ #category : 'accessing' }
ARGitHubEnvironment >> pullRequestCommentsUrl [

	^ 'https://api.github.com/repos/' , self repository , '/pulls/'
	  , self pullRequestNumber , '/comments'
]

{ #category : 'accessing' }
ARGitHubEnvironment >> pullRequestNumber [

	^ self requiredAt: 'PULL_REQUEST_NUMBER'
]

{ #category : 'accessing' }
ARGitHubEnvironment >> repository [

	^ self requiredAt: 'GITHUB_REPOSITORY'
]

{ #category : 'accessing' }
ARGitHubEnvironment >> repositoryName [

	^ self repositoryParts second
]

{ #category : 'accessing' }
ARGitHubEnvironment >> repositoryOwner [

	^ self repositoryParts first
]

{ #category : 'private' }
ARGitHubEnvironment >> repositoryParts [

	| parts |
	parts := self repository splitOn: '/'.
	parts size = 2 ifFalse: [
		self error: 'GITHUB_REPOSITORY must be formatted as owner/name' ].
	^ parts
]

{ #category : 'private' }
ARGitHubEnvironment >> requiredAt: aKey [

	^ self
		  valueAt: aKey
		  ifAbsent: [
		  self error:
			  aKey , ' is required in the GitHub Actions environment' ]
]

{ #category : 'accessing' }
ARGitHubEnvironment >> token [

	^ self valueAt: 'GITHUB_TOKEN' ifAbsent: [
			  self valueAt: 'PAT' ifAbsent: [
					  self error:
						  'GITHUB_TOKEN is required in the GitHub Actions environment. PAT is accepted for backward compatibility.' ] ]
]

{ #category : 'private' }
ARGitHubEnvironment >> valueAt: aKey ifAbsent: aBlock [

	| value |
	value := variables at: aKey ifAbsent: [ ^ aBlock value ].
	((value respondsTo: #isEmpty) and: [ value isEmpty ]) ifTrue: [
		^ aBlock value ].
	^ value
]

{ #category : 'accessing' }
ARGitHubEnvironment >> variables: anEnvironment [

	variables := anEnvironment
]
