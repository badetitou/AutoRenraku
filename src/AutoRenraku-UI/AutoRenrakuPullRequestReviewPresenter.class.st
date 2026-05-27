"
I provide a Spec UI to dry-run or post AutoRenraku suggestions for a GitHub pull request using the code currently loaded in the image.
"
Class {
	#name : 'AutoRenrakuPullRequestReviewPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'repositoryInput',
		'pullRequestNumberInput',
		'tokenInput',
		'dryRunButton',
		'postButton',
		'statusLabel',
		'warningsText',
		'resultsText',
		'client',
		'lastResult',
		'lastPullRequest'
	],
	#category : 'AutoRenraku-UI-UI',
	#package : 'AutoRenraku-UI',
	#tag : 'UI'
}

{ #category : 'accessing' }
AutoRenrakuPullRequestReviewPresenter class >> defaultPreferredExtent [

	^ 900 @ 700
]

{ #category : 'instance creation' }
AutoRenrakuPullRequestReviewPresenter class >> open [

	<script>
	^ self new open
]

{ #category : 'private' }
AutoRenrakuPullRequestReviewPresenter >> autoRenerakuForPullRequest: aPullRequest token: aToken [

	| auto classes |
	auto := AutoReneraku new.
	auto
		projectName: aPullRequest repositoryName;
		commitSha: aPullRequest headSha;
		url: aPullRequest commentsUrl.
	(aToken notNil and: [ aToken isNotEmpty ]) ifTrue: [
		auto token: aToken ].
	classes := auto classesFromChangedFiles: aPullRequest changedFiles.
	auto methodsToConsider:
		(classes flatCollect: [ :class | class methods ]).
	^ auto
]

{ #category : 'accessing' }
AutoRenrakuPullRequestReviewPresenter >> client [

	^ client ifNil: [ client := AutoRenrakuGitHubPullRequestClient new ]
]

{ #category : 'accessing' }
AutoRenrakuPullRequestReviewPresenter >> client: aClient [

	client := aClient
]

{ #category : 'private' }
AutoRenrakuPullRequestReviewPresenter >> confirmPostWithWarnings: warnings [

	^ self
		  confirm: 'AutoRenraku detected warnings:' , String cr , String cr
			  , (String cr join: warnings) , String cr , String cr
			  , 'Post comments anyway?'
		  label: 'Post AutoRenraku comments?'
]

{ #category : 'layout' }
AutoRenrakuPullRequestReviewPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		  add: 'Repository' expand: false;
		  add: repositoryInput expand: false;
		  add: 'Pull request number' expand: false;
		  add: pullRequestNumberInput expand: false;
		  add: 'Token' expand: false;
		  add: tokenInput expand: false;
		  add: (SpBoxLayout newLeftToRight
				   add: dryRunButton;
				   add: postButton;
				   yourself)
		  expand: false;
		  add: statusLabel expand: false;
		  add: 'Warnings' expand: false;
		  add: warningsText;
		  add: 'Results' expand: false;
		  add: resultsText;
		  yourself
]

{ #category : 'private' }
AutoRenrakuPullRequestReviewPresenter >> displayResult: aResult [

	statusLabel label: (self statusTextFor: aResult).
	warningsText text: (String cr join: aResult warnings).
	resultsText text: (self resultTextFor: aResult).
	^ aResult
]

{ #category : 'private' }
AutoRenrakuPullRequestReviewPresenter >> effectiveTokenFrom: aString [

	(aString notNil and: [ aString isNotEmpty ]) ifTrue: [ ^ aString ].
	^ self tokenFromEnvironment
]

{ #category : 'private' }
AutoRenrakuPullRequestReviewPresenter >> environmentForPullRequest: aPullRequest token: aToken [

	| variables |
	variables := Dictionary new.
	variables
		at: 'GITHUB_REPOSITORY' put: aPullRequest repository;
		at: 'PULL_REQUEST_NUMBER' put: aPullRequest number asString;
		at: 'COMMIT_SHA' put: aPullRequest headSha;
		at: 'GITHUB_TOKEN' put: ((aToken isNil or: [ aToken isEmpty ])
				 ifTrue: [ 'dry-run' ]
				 ifFalse: [ aToken ]).
	^ ARGitHubEnvironment on: variables
]

{ #category : 'initialization' }
AutoRenrakuPullRequestReviewPresenter >> initialize [

	super initialize.
	client := AutoRenrakuGitHubPullRequestClient new
]

{ #category : 'initialization' }
AutoRenrakuPullRequestReviewPresenter >> initializePresenters [

	repositoryInput := self newTextInput.
	repositoryInput text: AutoRenrakuUISettings defaultRepository.
	pullRequestNumberInput := self newTextInput.
	pullRequestNumberInput text:
		AutoRenrakuUISettings lastPullRequestNumber.
	tokenInput := self newTextInput.
	tokenInput
		bePassword;
		placeholder: 'GitHub token (not stored)'.
	dryRunButton := self newButton.
	dryRunButton
		label: 'Dry run';
		action: [ self runDryFromUI ].
	postButton := self newButton.
	postButton
		label: 'Post comments';
		action: [ self postFromUI ].
	statusLabel := self newLabel.
	statusLabel label: 'Ready'.
	warningsText := self newText.
	warningsText beNotEditable.
	resultsText := self newText.
	resultsText beNotEditable.
	self layout: self defaultLayout
]

{ #category : 'accessing' }
AutoRenrakuPullRequestReviewPresenter >> lastPullRequest [

	^ lastPullRequest
]

{ #category : 'accessing' }
AutoRenrakuPullRequestReviewPresenter >> lastResult [

	^ lastResult
]

{ #category : 'private' }
AutoRenrakuPullRequestReviewPresenter >> postFromUI [

	| result |
	self rememberInputs.
	statusLabel label: 'Posting comments...'.
	result := self
		          postPullRequestNumber: self pullRequestNumberFromUI
		          repository: self repositoryFromUI
		          token: self tokenFromUI.
	self displayResult: result.
	^ result
]

{ #category : 'api' }
AutoRenrakuPullRequestReviewPresenter >> postPullRequestNumber: aNumber repository: aRepository token: aToken [

	| effectiveToken pullRequest auto result warnings |
	effectiveToken := self effectiveTokenFrom: aToken.
	(effectiveToken isNil or: [ effectiveToken isEmpty ]) ifTrue: [
			result := ARReviewRunResult new.
			result recordWarning:
				'A GitHub token is required to post AutoRenraku comments.'.
			lastResult := result.
			^ result ].
	self client token: effectiveToken.
	pullRequest := self client
		               pullRequest: aNumber
		               repository: aRepository.
	lastPullRequest := pullRequest.
	auto := self
		        autoRenerakuForPullRequest: pullRequest
		        token: effectiveToken.
	warnings := AutoRenrakuImagePullRequestAlignmentChecker
		            warningsForPullRequest: pullRequest
		            autoReneraku: auto.
	(warnings isNotEmpty and: [
		 (self confirmPostWithWarnings: warnings) not ]) ifTrue: [
			result := ARReviewRunResult new.
			warnings do: [ :warning | result recordWarning: warning ].
			lastResult := result.
			^ result ].
	result := auto run.
	warnings do: [ :warning | result recordWarning: warning ].
	lastResult := result.
	^ result
]

{ #category : 'private' }
AutoRenrakuPullRequestReviewPresenter >> pullRequestNumberFromUI [

	^ pullRequestNumberInput text asString asInteger
]

{ #category : 'private' }
AutoRenrakuPullRequestReviewPresenter >> recordAlignmentWarningsFor: aPullRequest autoReneraku: anAutoReneraku in: aResult [

	(AutoRenrakuImagePullRequestAlignmentChecker
		 warningsForPullRequest: aPullRequest
		 autoReneraku: anAutoReneraku) do: [ :warning |
		aResult recordWarning: warning ].
	^ aResult
]

{ #category : 'private' }
AutoRenrakuPullRequestReviewPresenter >> rememberInputs [

	AutoRenrakuUISettings defaultRepository: self repositoryFromUI.
	AutoRenrakuUISettings lastPullRequestNumber:
		self pullRequestNumberFromUI asString
]

{ #category : 'private' }
AutoRenrakuPullRequestReviewPresenter >> repositoryFromUI [

	^ repositoryInput text asString
]

{ #category : 'private' }
AutoRenrakuPullRequestReviewPresenter >> resultTextFor: aResult [

	^ String streamContents: [ :stream |
			  stream
				  << 'Built suggestions: ';
				  << aResult builtSuggestions size asString;
				  cr;
				  << 'Posted suggestions: ';
				  << aResult postedSuggestions size asString;
				  cr;
				  << 'Corrected methods: ';
				  << aResult correctedMethods size asString;
				  cr;
				  << 'Ignored methods: ';
				  << aResult ignoredMethods size asString;
				  cr;
				  << 'Errored methods: ';
				  << aResult erroredMethods size asString;
				  cr.
			  aResult builtSuggestions ifNotEmpty: [
					  stream
						  cr;
						  << 'Suggestions:';
						  cr.
					  aResult builtSuggestions do: [ :suggestion |
							  stream
								  << (suggestion
										   at: #path
										   ifAbsent: [ suggestion at: 'path' ifAbsent: [ '' ] ]);
								  << ' line ';
								  << (suggestion
										   at: #line
										   ifAbsent: [ suggestion at: 'line' ifAbsent: [ '' ] ])
										  asString;
								  cr ] ] ]
]

{ #category : 'private' }
AutoRenrakuPullRequestReviewPresenter >> runDryFromUI [

	| result |
	self rememberInputs.
	statusLabel label: 'Running dry run...'.
	result := self
		          runDryPullRequestNumber: self pullRequestNumberFromUI
		          repository: self repositoryFromUI
		          token: self tokenFromUI.
	self displayResult: result.
	^ result
]

{ #category : 'api' }
AutoRenrakuPullRequestReviewPresenter >> runDryPullRequestNumber: aNumber repository: aRepository token: aToken [

	| effectiveToken pullRequest auto result |
	effectiveToken := self effectiveTokenFrom: aToken.
	self client token: effectiveToken.
	pullRequest := self client
		               pullRequest: aNumber
		               repository: aRepository.
	lastPullRequest := pullRequest.
	auto := self
		        autoRenerakuForPullRequest: pullRequest
		        token: effectiveToken.
	result := auto runDry.
	self
		recordAlignmentWarningsFor: pullRequest
		autoReneraku: auto
		in: result.
	lastResult := result.
	^ result
]

{ #category : 'private' }
AutoRenrakuPullRequestReviewPresenter >> statusTextFor: aResult [

	aResult hasErrors ifTrue: [ ^ 'Completed with errors' ].
	aResult hasWarnings ifTrue: [ ^ 'Completed with warnings' ].
	^ 'Completed'
]

{ #category : 'private' }
AutoRenrakuPullRequestReviewPresenter >> tokenFromEnvironment [

	^ Smalltalk os environment
		  at: 'GITHUB_TOKEN'
		  ifAbsent: [ Smalltalk os environment at: 'PAT' ifAbsent: [ '' ] ]
]

{ #category : 'private' }
AutoRenrakuPullRequestReviewPresenter >> tokenFromUI [

	^ tokenInput text asString
]
