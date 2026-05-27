"
I represent the GitHub pull request metadata AutoRenraku needs to run from an existing pull request without posting comments by default.
"
Class {
	#name : 'AutoRenrakuGitHubPullRequest',
	#superclass : 'Object',
	#instVars : [
		'repository',
		'number',
		'headSha',
		'changedFiles',
		'commentsUrl'
	],
	#category : 'AutoRenraku-UI-Model',
	#package : 'AutoRenraku-UI',
	#tag : 'Model'
}

{ #category : 'instance creation' }
AutoRenrakuGitHubPullRequest class >> repository: aRepository number: aNumber headSha: aSha changedFiles: fileNames commentsUrl: aUrl [

	^ self new
		  repository: aRepository;
		  number: aNumber;
		  headSha: aSha;
		  changedFiles: fileNames;
		  commentsUrl: aUrl;
		  yourself
]

{ #category : 'accessing' }
AutoRenrakuGitHubPullRequest >> changedFiles [

	^ changedFiles ifNil: [ #(  ) ]
]

{ #category : 'accessing' }
AutoRenrakuGitHubPullRequest >> changedFiles: aCollection [

	changedFiles := aCollection asArray
]

{ #category : 'accessing' }
AutoRenrakuGitHubPullRequest >> commentsUrl [

	^ commentsUrl
]

{ #category : 'accessing' }
AutoRenrakuGitHubPullRequest >> commentsUrl: aString [

	commentsUrl := aString
]

{ #category : 'accessing' }
AutoRenrakuGitHubPullRequest >> headSha [

	^ headSha
]

{ #category : 'accessing' }
AutoRenrakuGitHubPullRequest >> headSha: aString [

	headSha := aString
]

{ #category : 'accessing' }
AutoRenrakuGitHubPullRequest >> number [

	^ number
]

{ #category : 'accessing' }
AutoRenrakuGitHubPullRequest >> number: anObject [

	number := anObject
]

{ #category : 'accessing' }
AutoRenrakuGitHubPullRequest >> repository [

	^ repository
]

{ #category : 'accessing' }
AutoRenrakuGitHubPullRequest >> repository: aString [

	repository := aString
]

{ #category : 'accessing' }
AutoRenrakuGitHubPullRequest >> repositoryName [

	| parts |
	parts := self repository splitOn: '/'.
	parts size = 2 ifFalse: [ ^ self repository ].
	^ parts second
]
