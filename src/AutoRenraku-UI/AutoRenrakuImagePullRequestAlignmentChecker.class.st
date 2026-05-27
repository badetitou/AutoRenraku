"
I produce user-facing warnings when the loaded image may not match the GitHub pull request being reviewed.
"
Class {
	#name : 'AutoRenrakuImagePullRequestAlignmentChecker',
	#superclass : 'Object',
	#category : 'AutoRenraku-UI-GitHub',
	#package : 'AutoRenraku-UI',
	#tag : 'GitHub'
}

{ #category : 'api' }
AutoRenrakuImagePullRequestAlignmentChecker class >> warningsForPullRequest: aPullRequest autoReneraku: anAutoReneraku [

	^ self new
		  warningsForPullRequest: aPullRequest
		  autoReneraku: anAutoReneraku
]

{ #category : 'private' }
AutoRenrakuImagePullRequestAlignmentChecker >> headCommitIdOf: aRepository [

	^ aRepository headCommit id
]

{ #category : 'private' }
AutoRenrakuImagePullRequestAlignmentChecker >> missingClassNamesForChangedFiles: changedFiles [

	| classNames |
	classNames := changedFiles collect: [ :file |
		              self tonelClassNameFromFile: file ].
	classNames := classNames reject: [ :className | className isNil ].
	^ (classNames reject: [ :className |
		   (Smalltalk classNamed: className) notNil ]) asSet asArray
]

{ #category : 'private' }
AutoRenrakuImagePullRequestAlignmentChecker >> repository: aRepository matchesHeadSha: aSha [

	| head |
	head := self headCommitIdOf: aRepository.
	^ head = aSha or: [
			  head notNil and: [
				  (aSha beginsWith: head) or: [ head beginsWith: aSha ] ] ]
]

{ #category : 'private' }
AutoRenrakuImagePullRequestAlignmentChecker >> repositoryNamed: aRepositoryName [

	^ IceRepository registry
		  detect: [ :each | each name = aRepositoryName ]
		  ifNone: [ nil ]
]

{ #category : 'private' }
AutoRenrakuImagePullRequestAlignmentChecker >> tonelClassNameFromFile: aFileName [

	| basename suffix |
	suffix := '.class.st'.
	(aFileName asString endsWith: suffix) ifFalse: [ ^ nil ].
	basename := (aFileName asString splitOn: '/') last.
	^ basename copyFrom: 1 to: basename size - suffix size
]

{ #category : 'api' }
AutoRenrakuImagePullRequestAlignmentChecker >> warningsForPullRequest: aPullRequest autoReneraku: anAutoReneraku [

	| warnings repository missingClasses head |
	warnings := OrderedCollection new.
	repository := self repositoryNamed: aPullRequest repositoryName.
	repository
		ifNil: [
				warnings add:
					'Unable to verify image checkout: no Iceberg repository named '
					, aPullRequest repositoryName
					,
					' is registered. Dry-run uses the code currently loaded in this image.' ]
		ifNotNil: [
				(self repository: repository matchesHeadSha: aPullRequest headSha)
					ifFalse: [
							head := self headCommitIdOf: repository.
							warnings add:
								'Dry-run uses the code currently loaded in this image. Pull request head is '
								, aPullRequest headSha
								, ', but the registered repository is at ' , head
								,
								'. Load or checkout the PR head in the image for accurate suggestions.' ] ].
	missingClasses := self missingClassNamesForChangedFiles:
		                  aPullRequest changedFiles.
	missingClasses ifNotEmpty: [
			warnings add:
				'Some changed classes are not loaded in the image and were ignored: '
				, (', ' join: missingClasses) ].
	anAutoReneraku methodsToConsider isEmpty ifTrue: [
			warnings add:
				'No methods selected from pull request changed files. Check that the PR branch is loaded in the image.' ].
	^ warnings asArray
]
