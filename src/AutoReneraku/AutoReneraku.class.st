Class {
	#name : 'AutoReneraku',
	#superclass : 'Object',
	#instVars : [
		'client',
		'critiques',
		'projectName',
		'methodsToConsider',
		'url',
		'commitSha',
		'suggestionBuilders',
		'dryRun'
	],
	#category : 'AutoReneraku',
	#package : 'AutoReneraku'
}

{ #category : 'private' }
AutoReneraku >> applyCritiques: aCollection to: aMethod [

	self rememberSuggestionBuilderFor: aMethod.
	aCollection do: [ :critique | critique change execute ]
]

{ #category : 'api' }
AutoReneraku >> autoCorrectMethod: aMethod [
	"I return true if I applied some modification"

	| toApplyCritique |
	toApplyCritique := self critiquesToApplyFor: aMethod.
	toApplyCritique ifEmpty: [ ^ false ].
	self applyCritiques: toApplyCritique to: aMethod.
	^ true
]

{ #category : 'api' }
AutoReneraku >> autoRenerakuMethod: aMethod [
	"I return true if I applied some modification"

	^ (self autoRenerakuMethod: aMethod dryRun: self dryRun) notNil
]

{ #category : 'api' }
AutoReneraku >> autoRenerakuMethod: aMethod dryRun: aBoolean [

	| savedDefinition toApplyCritique suggestion |
	savedDefinition := aMethod.
	toApplyCritique := self critiquesToApplyFor: aMethod.
	toApplyCritique ifEmpty: [ ^ nil ].
	[
		self applyCritiques: toApplyCritique to: aMethod.
		suggestion := aBoolean
			              ifTrue: [ self buildSuggestionForMethod: aMethod ]
			              ifFalse: [ self suggestNewMethod: aMethod ].
		^ suggestion ] ensure: [
			savedDefinition methodClass
				compile: savedDefinition sourceCode
				classified: savedDefinition protocol ]
]

{ #category : 'api' }
AutoReneraku >> beDryRun [

	self dryRun: true.
	^ self
]

{ #category : 'api' }
AutoReneraku >> bePosting [

	self dryRun: false.
	^ self
]

{ #category : 'private' }
AutoReneraku >> buildBodyOf: data basedOn: aMethod [

	data at: #body put: (self suggestionBuilderFor: aMethod) body
]

{ #category : 'private' }
AutoReneraku >> buildLineOf: data basedOn: method [

	data at: #line put: (self suggestionBuilderFor: method) line
]

{ #category : 'private' }
AutoReneraku >> buildPathOf: data basedOn: method [

	data at: #path put: (self suggestionBuilderFor: method) path
]

{ #category : 'private' }
AutoReneraku >> buildStartLineOf: data basedOn: method [

	data
		at: #start_line
		put: (self suggestionBuilderFor: method) startLine
]

{ #category : 'private' }
AutoReneraku >> buildSuggestionForMethod: aMethod [

	| data |
	data := Dictionary new.
	data at: 'commit_id' put: commitSha.
	self fillData: data withNewMethodData: aMethod.
	^ data
]

{ #category : 'private' }
AutoReneraku >> classNameFromChangedFile: aFileName [

	| basename |
	basename := (aFileName asString splitOn: '/') last.
	^ (basename splitOn: '.') first
]

{ #category : 'private' }
AutoReneraku >> classNamesFromChangedFiles: changedFileNames [

	^ ((changedFileNames collect: [ :file |
		    self classNameFromChangedFile: file ]) reject: [ :className |
		   className isEmpty ]) asSet asArray
]

{ #category : 'private' }
AutoReneraku >> classesFromChangedFiles: changedFileNames [

	| classes |
	classes := (self classNamesFromChangedFiles: changedFileNames)
		           collect: [ :className | Smalltalk classNamed: className ].
	^ classes reject: [ :clazz | clazz isNil ]
]

{ #category : 'accessing' }
AutoReneraku >> commitSha [

	^ commitSha
]

{ #category : 'accessing' }
AutoReneraku >> commitSha: anObject [

	commitSha := anObject
]

{ #category : 'accessing' }
AutoReneraku >> computeDiffStartOffsetFor: method [

	^ (self suggestionBuilderFor: method) diffStartOffset
]

{ #category : 'accessing' }
AutoReneraku >> computeDiffStopOffsetFor: method [

	^ (self suggestionBuilderFor: method) diffStopOffset
]

{ #category : 'accessing' }
AutoReneraku >> computeDifferencesFor: method [

	^ (self suggestionBuilderFor: method) differences
]

{ #category : 'private' }
AutoReneraku >> considerChangedFiles: changedFileNames [

	methodsToConsider := (self classesFromChangedFiles: changedFileNames)
		                     flatCollect: [ :clazz | clazz methods ]
]

{ #category : 'private' }
AutoReneraku >> critiquesToApplyFor: aMethod [

	(self isMethodFormatted: aMethod) ifFalse: [ ^ #(  ) ].
	critiques := aMethod critiques.
	^ critiques select: [ :critique | critique providesChange ]
]

{ #category : 'accessing' }
AutoReneraku >> dryRun [

	^ dryRun ifNil: [ false ]
]

{ #category : 'accessing' }
AutoReneraku >> dryRun: aBoolean [

	dryRun := aBoolean.
	^ self
]

{ #category : 'accessing' }
AutoReneraku >> extractStartPosOf: method [

	^ (self suggestionBuilderFor: method) methodStartCharacter
]

{ #category : 'private' }
AutoReneraku >> fillData: data withNewMethodData: aMethod [

	^ (self suggestionBuilderFor: aMethod) fillData: data
]

{ #category : 'initialization' }
AutoReneraku >> initialize [

	super initialize.
	client := ZnClient new.
	client forJsonREST.
	methodsToConsider := #(  ).
	suggestionBuilders := Dictionary new.
	dryRun := false
]

{ #category : 'accessing' }
AutoReneraku >> isMethodFormatted: aMethod [
	"Autoreneraku cannot apply on method not formatted. So we need to check this information first"

	^ aMethod sourceCode = aMethod ast formattedCode
]

{ #category : 'private' }
AutoReneraku >> methodConcernedBy: renerakuCritic [

	^ renerakuCritic entity methodNode compiledMethod
]

{ #category : 'accessing' }
AutoReneraku >> methodsToConsider [

	^ methodsToConsider
]

{ #category : 'accessing' }
AutoReneraku >> methodsToConsider: aCollection [

	methodsToConsider := aCollection
]

{ #category : 'private' }
AutoReneraku >> post: url contents: someData [

	^ client post: url contents: someData
]

{ #category : 'api' }
AutoReneraku >> prepareAutoReneraku [

	^ self prepareAutoRenerakuWithEnvironment:
		  ARGitHubEnvironment current
]

{ #category : 'api' }
AutoReneraku >> prepareAutoRenerakuWithChangedFiles: changedFileNames [

	^ self
		  prepareAutoRenerakuWithEnvironment: ARGitHubEnvironment current
		  changedFiles: changedFileNames
]

{ #category : 'api' }
AutoReneraku >> prepareAutoRenerakuWithEnvironment: aGitHubEnvironment [

	projectName := aGitHubEnvironment projectName.
	self registerCurrentRepository.
	self token: aGitHubEnvironment token.
	url := aGitHubEnvironment pullRequestCommentsUrl.
	commitSha := aGitHubEnvironment commitSha
]

{ #category : 'api' }
AutoReneraku >> prepareAutoRenerakuWithEnvironment: aGitHubEnvironment changedFiles: changedFileNames [

	self prepareAutoRenerakuWithEnvironment: aGitHubEnvironment.
	self considerChangedFiles: changedFileNames
]

{ #category : 'accessing' }
AutoReneraku >> projectName [

	^ projectName
]

{ #category : 'accessing' }
AutoReneraku >> projectName: anObject [

	projectName := anObject
]

{ #category : 'private' }
AutoReneraku >> registerCurrentRepository [

	[
		(IceRepositoryCreator new
			 location: '.' asFileReference;
			 subdirectory: 'src';
			 createRepository)
			name: projectName;
			register ]
		on: IceDuplicatedRepository
		do: [
				Stdio stderr << 'Repository already installed in the image'.
				Stdio stderr << IceRepository registry printString ]
]

{ #category : 'private' }
AutoReneraku >> rememberSuggestionBuilderFor: aMethod [

	suggestionBuilders ifNil: [ suggestionBuilders := Dictionary new ].
	suggestionBuilders
		at: (self suggestionBuilderKeyFor: aMethod)
		put: (ARTonelSuggestionBuilder forOriginalMethod: aMethod)
]

{ #category : 'private' }
AutoReneraku >> reviewMethod: aMethod into: aResult dryRun: aBoolean [

	[
		| suggestion |
		suggestion := self autoRenerakuMethod: aMethod dryRun: aBoolean.
		suggestion
			ifNil: [ aResult recordIgnoredMethod: aMethod ]
			ifNotNil: [
					aResult recordCorrectedMethod: aMethod suggestion: suggestion.
					aBoolean ifFalse: [ aResult recordPostedSuggestion: suggestion ] ] ]
		on: Error
		do: [ :error | aResult recordError: error forMethod: aMethod ]
]

{ #category : 'api' }
AutoReneraku >> run [

	^ self runDryRun: self dryRun
]

{ #category : 'api' }
AutoReneraku >> runDry [

	^ self runDryRun: true
]

{ #category : 'api' }
AutoReneraku >> runDryRun: aBoolean [

	| result |
	result := ARReviewRunResult new.
	methodsToConsider do: [ :method |
		self reviewMethod: method into: result dryRun: aBoolean ].
	^ result
]

{ #category : 'api' }
AutoReneraku >> suggestNewMethod: aMethod [

	| data |
	data := self buildSuggestionForMethod: aMethod.
	self post: url contents: data.
	^ data
]

{ #category : 'private' }
AutoReneraku >> suggestionBuilderFor: aMethod [

	suggestionBuilders ifNil: [ suggestionBuilders := Dictionary new ].
	^ suggestionBuilders
		  at: (self suggestionBuilderKeyFor: aMethod)
		  ifAbsentPut: [
		  ARTonelSuggestionBuilder forOriginalMethod: aMethod ]
]

{ #category : 'private' }
AutoReneraku >> suggestionBuilderKeyFor: aMethod [

	^ {
		  aMethod methodClass instanceSide name.
		  aMethod methodClass isMeta.
		  aMethod selector }
]

{ #category : 'accessing' }
AutoReneraku >> token: aToken [

	client headerAt: #Authorization add: 'token ' , aToken
]

{ #category : 'accessing' }
AutoReneraku >> url [

	^ url
]

{ #category : 'accessing' }
AutoReneraku >> url: anObject [

	url := anObject
]
