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
		'suggestionBuilders'
	],
	#category : 'AutoReneraku',
	#package : 'AutoReneraku'
}

{ #category : 'api' }
AutoReneraku >> autoCorrectMethod: aMethod [
	"I return true if I applied some modification"

	| toApplyCritique |
	(self isMethodFormatted: aMethod) ifFalse: [ ^ false ].
	critiques := aMethod critiques.
	toApplyCritique := critiques select: [ :critique |
		                   critique providesChange ].
	toApplyCritique ifEmpty: [ ^ false ].
	self rememberSuggestionBuilderFor: aMethod.
	toApplyCritique do: [ :critique | critique change execute ].
	^ true
]

{ #category : 'api' }
AutoReneraku >> autoRenerakuMethod: aMethod [
	"I return true if I applied some modification"

	| savedDefinition |
	savedDefinition := aMethod.
	^ (self autoCorrectMethod: aMethod) ifTrue: [
		  self suggestNewMethod: aMethod.
		  savedDefinition methodClass compile: savedDefinition sourceCode ]
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
	suggestionBuilders := Dictionary new
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

{ #category : 'api' }
AutoReneraku >> run [

	methodsToConsider do: [ :method | self autoRenerakuMethod: method ]
]

{ #category : 'api' }
AutoReneraku >> suggestNewMethod: aMethod [

	| data |
	data := Dictionary new.
	data at: 'commit_id' put: commitSha.
	self fillData: data withNewMethodData: aMethod.
	^ self post: url contents: data
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
