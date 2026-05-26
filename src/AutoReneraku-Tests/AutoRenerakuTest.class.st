"
An AutoRenerakuTest is a test class for testing the behavior of AutoReneraku
"
Class {
	#name : 'AutoRenerakuTest',
	#superclass : 'TestCase',
	#instVars : [
		'autoreneraku'
	],
	#category : 'AutoReneraku-Tests',
	#package : 'AutoReneraku-Tests'
}

{ #category : 'fixtures' }
AutoRenerakuTest >> completeRemovalFixtureSource [

	^ String cr join:
		  #( 'testOutside' '' '	| outside |' '	self flag: ''We should improve this method''.'
		     '	outside := 1 > 2' '		           ifTrue: [ 3 ]'
		     '		           ifFalse: [ 4 ]' )
]

{ #category : 'fixtures' }
AutoRenerakuTest >> completeRemovalMethod [

	^ AutoRenerakuTestSampleWithFlag >> #testOutside
]

{ #category : 'fixtures' }
AutoRenerakuTest >> correctableFixtureSource [

	^ String cr join:
		  #( 'testOutside' '' '	| outside |' '	1 > 2' '		ifTrue: [ outside := 3 ]'
		     '		ifFalse: [ outside := 4 ]' )
]

{ #category : 'fixtures' }
AutoRenerakuTest >> correctableMethod [

	^ AutoRenerakuTestSample >> #testOutside
]

{ #category : 'fixtures' }
AutoRenerakuTest >> installFixtureMethods [

	AutoRenerakuTestSample
		compile: self correctableFixtureSource
		classified: 'tests'.
	AutoRenerakuTestSampleSubClass
		compile: self protocolOnlyChangeFixtureSource
		classified: 'execution'.
	AutoRenerakuTestSampleWithFlag
		compile: self completeRemovalFixtureSource
		classified: 'tests'.
	AutoRenerakuTestSampleWithFlag
		compile: self multiStatementRemovalFixtureSource
		classified: 'tests'.
	AutoRenerakuTestSampleWithFlag
		compile: self notFormattedFixtureSource
		classified: 'tests'
]

{ #category : 'fixtures' }
AutoRenerakuTest >> multiStatementRemovalFixtureSource [

	^ String cr join:
		  #( 'testOutsideMultiStatementFlag' '	"with comment"'
		     '' '	| outside |' '	outside := 1 > 2' '		           ifTrue: [ 3 ]'
		     '		           ifFalse: [ 4 ].' '	self flag: ''We should improve this method''.'
		     '	outside := 1 > 2' '		           ifTrue: [ 3 ]'
		     '		           ifFalse: [ 4 ]' )
]

{ #category : 'fixtures' }
AutoRenerakuTest >> multiStatementRemovalMethod [

	^ AutoRenerakuTestSampleWithFlag >> #testOutsideMultiStatementFlag
]

{ #category : 'fixtures' }
AutoRenerakuTest >> notFormattedFixtureSource [

	^ String cr join: #( 'testOutsideMultiStatementFlagNotFormatted'
		     '	"with comment"' '' '	| outside |' '	outside := 1 > 2 ifTrue: [ 3 ] ifFalse: [ 4 ].'
		     '	self flag: ''We should improve this method''.'
		     '	outside := 1 > 2 ifTrue: [ 3 ] ifFalse: [ 4 ]' )
]

{ #category : 'fixtures' }
AutoRenerakuTest >> notFormattedMethod [

	^ AutoRenerakuTestSampleWithFlag
	  >> #testOutsideMultiStatementFlagNotFormatted
]

{ #category : 'fixtures' }
AutoRenerakuTest >> protocolOnlyChangeFixtureSource [

	^ String cr join:
		  #( 'testOutside' '' '	| outside |' '	outside := 1 > 2'
		     '		           ifTrue: [ 3 ]' '		           ifFalse: [ 4 ]' )
]

{ #category : 'fixtures' }
AutoRenerakuTest >> protocolOnlyChangeMethod [

	^ AutoRenerakuTestSampleSubClass >> #testOutside
]

{ #category : 'running' }
AutoRenerakuTest >> setUp [

	super setUp.
	self installFixtureMethods.

	autoreneraku := AutoReneraku new.
	autoreneraku projectName: 'AutoReneraku'
]

{ #category : 'running' }
AutoRenerakuTest >> tearDown [

	[ self installFixtureMethods ] ensure: [ super tearDown ]
]

{ #category : 'tests' }
AutoRenerakuTest >> testAutoRenerakuMethodSkipsNotFormattedSuggestion [

	| method |
	method := self notFormattedMethod.
	(autoreneraku stub suggestNewMethod: Any) willReturn: true.
	autoreneraku autoRenerakuMethod: method.
	autoreneraku should not receive suggestNewMethod: Any
]

{ #category : 'tests' }
AutoRenerakuTest >> testBuildBodyOfBasedOn [

	| method data |
	method := self correctableMethod.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	autoreneraku buildBodyOf: data basedOn: method.
	self assert: (data at: #body) equals: '```suggestion
	outside := 1 > 2
		           ifTrue: [ 3 ]
		           ifFalse: [ 4 ]
```'
]

{ #category : 'tests' }
AutoRenerakuTest >> testBuildBodyOfBasedOnForProtocol [

	| method data |
	method := self protocolOnlyChangeMethod.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	autoreneraku buildBodyOf: data basedOn: method.
	self assert: (data at: #body) equals: '```suggestion
{ #category : ''tests'' }
```'
]

{ #category : 'tests' }
AutoRenerakuTest >> testBuildBodyOfBasedOnForRemoval [

	| method data |
	method := self completeRemovalMethod.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	autoreneraku buildBodyOf: data basedOn: method.
	"At least it should be removed (and replace with nothing, why not?)"
	self assert: (data at: #body) equals: '```suggestion

```'
]

{ #category : 'tests' }
AutoRenerakuTest >> testBuildBodyOfBasedOnForRemovalMultiStatement [

	| method data |
	method := self multiStatementRemovalMethod.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	autoreneraku buildBodyOf: data basedOn: method.
	"At least it should be removed (and replace with nothing, why not?)"
	self assert: (data at: #body) equals: '```suggestion

```'
]

{ #category : 'tests' }
AutoRenerakuTest >> testBuildLineOfBasedOn [

	| method data |
	method := self correctableMethod.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	autoreneraku buildLineOf: data basedOn: method.
	self assert: (data at: #line) equals: 18
]

{ #category : 'tests' }
AutoRenerakuTest >> testBuildStartLineOfBasedOn [

	| method data |
	method := self correctableMethod.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	autoreneraku buildStartLineOf: data basedOn: method.
	self assert: (data at: #start_line) equals: 16
]

{ #category : 'tests' }
AutoRenerakuTest >> testClassNameFromChangedFileParsesTonelPath [

	self
		assert: (autoreneraku classNameFromChangedFile:
				 'src/AutoReneraku/AutoReneraku.class.st')
		equals: 'AutoReneraku'
]

{ #category : 'tests' }
AutoRenerakuTest >> testComputeDiffStartOffsetFor [

	| method |
	method := self correctableMethod.
	autoreneraku autoCorrectMethod: method.
	self
		assert: (autoreneraku computeDiffStartOffsetFor: method)
		equals: 5
]

{ #category : 'tests' }
AutoRenerakuTest >> testComputeDiffStartOffsetForProtocolUpdate [

	| method |
	method := self protocolOnlyChangeMethod.
	autoreneraku autoCorrectMethod: method.
	self
		assert: (autoreneraku computeDiffStartOffsetFor: method)
		equals: 1
]

{ #category : 'tests' }
AutoRenerakuTest >> testComputeDiffStartOffsetForRemoval [

	| method |
	method := self completeRemovalMethod.
	autoreneraku autoCorrectMethod: method.
	self
		assert: (autoreneraku computeDiffStartOffsetFor: method)
		equals: 5
]

{ #category : 'tests' }
AutoRenerakuTest >> testComputeDiffStopOffsetFor [

	| method |
	method := self correctableMethod.
	autoreneraku autoCorrectMethod: method.
	self
		assert: (autoreneraku computeDiffStopOffsetFor: method)
		equals: 3
]

{ #category : 'tests' }
AutoRenerakuTest >> testComputeDiffStopOffsetForProtocolUpdate [

	| method |
	method := self protocolOnlyChangeMethod.
	autoreneraku autoCorrectMethod: method.
	self
		assert: (autoreneraku computeDiffStopOffsetFor: method)
		equals: 1
]

{ #category : 'tests' }
AutoRenerakuTest >> testComputeDiffStopOffsetForRemoval [

	| method |
	method := self completeRemovalMethod.
	autoreneraku autoCorrectMethod: method.
	self
		assert: (autoreneraku computeDiffStopOffsetFor: method)
		equals: 0
]

{ #category : 'tests' }
AutoRenerakuTest >> testDiffStartOutsideMultiStatementFlag [

	| method |
	method := self multiStatementRemovalMethod.
	autoreneraku autoCorrectMethod: method.
	self
		assert: (autoreneraku computeDiffStartOffsetFor: method)
		equals: 9
]

{ #category : 'tests' }
AutoRenerakuTest >> testDiffStopOutsideMultiStatementFlag [

	| method |
	method := self multiStatementRemovalMethod.
	autoreneraku autoCorrectMethod: method.
	self
		assert: (autoreneraku computeDiffStopOffsetFor: method)
		equals: 0
]

{ #category : 'tests' }
AutoRenerakuTest >> testFillDataWithNewMethodData [

	| method data |
	method := self correctableMethod.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	autoreneraku fillData: data withNewMethodData: method.
	self assert: data size equals: 4
]

{ #category : 'tests' }
AutoRenerakuTest >> testFillDataWithNewMethodDataWhenOneLineUpdate [

	| method data |
	method := self protocolOnlyChangeMethod.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	autoreneraku fillData: data withNewMethodData: method.
	self assert: data size equals: 3
]

{ #category : 'tests' }
AutoRenerakuTest >> testFillDataWithNewMethodDataWhenRemove [

	| method data |
	method := self completeRemovalMethod.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	autoreneraku fillData: data withNewMethodData: method.
	self assert: data size equals: 3
]

{ #category : 'tests' }
AutoRenerakuTest >> testNotFirstMethodInTonel [

	| method2 data |
	(autoreneraku stub suggestNewMethod: Any) willReturn: true.

	autoreneraku autoRenerakuMethod: self completeRemovalMethod.
	autoreneraku autoRenerakuMethod: self notFormattedMethod.

	method2 := self multiStatementRemovalMethod.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method2.
	autoreneraku buildLineOf: data basedOn: method2.
	self assert: (data at: #line) equals: 30
]

{ #category : 'tests' }
AutoRenerakuTest >> testNotFormattedDoNothing [

	| method |
	method := self notFormattedMethod.
	self deny: (autoreneraku isMethodFormatted: method).
	self deny: (autoreneraku autoCorrectMethod: method)
]

{ #category : 'tests' }
AutoRenerakuTest >> testPrepareAutoRenerakuDoesNotRequireChangedFilesEnvironmentVariable [

	| environment |
	environment := ARGitHubEnvironment on: (Dictionary new
			                at: 'GITHUB_REPOSITORY' put: 'owner/AutoReneraku';
			                at: 'GITHUB_TOKEN' put: 'github-token';
			                at: 'PULL_REQUEST_NUMBER' put: '42';
			                at: 'COMMIT_SHA' put: 'abc123';
			                yourself).
	autoreneraku stub registerCurrentRepository willReturn: true.
	(autoreneraku stub token: Any) willReturn: true.

	autoreneraku prepareAutoRenerakuWithEnvironment: environment.

	self assert: autoreneraku methodsToConsider isEmpty.
	autoreneraku should receive token: 'github-token'
]

{ #category : 'tests' }
AutoRenerakuTest >> testPrepareAutoRenerakuUsesInjectedChangedFiles [

	| environment changedFileNames |
	environment := ARGitHubEnvironment on: (Dictionary new
			                at: 'GITHUB_REPOSITORY' put: 'owner/AutoReneraku';
			                at: 'GITHUB_TOKEN' put: 'github-token';
			                at: 'PAT' put: 'legacy-token';
			                at: 'PULL_REQUEST_NUMBER' put: '42';
			                at: 'COMMIT_SHA' put: 'abc123';
			                yourself).
	changedFileNames := #( 'src/AutoReneraku-Tests/AutoRenerakuTestSample.class.st'
	                       'README.md' 'src/AutoReneraku-Tests/MissingClass.class.st' ).
	autoreneraku stub registerCurrentRepository willReturn: true.
	(autoreneraku stub token: Any) willReturn: true.

	autoreneraku
		prepareAutoRenerakuWithEnvironment: environment
		changedFiles: changedFileNames.

	self assert: autoreneraku projectName equals: 'AutoReneraku'.
	self assert: autoreneraku commitSha equals: 'abc123'.
	self
		assert: autoreneraku url
		equals:
		'https://api.github.com/repos/owner/AutoReneraku/pulls/42/comments'.
	self assert:
		(autoreneraku methodsToConsider includes: self correctableMethod).
	autoreneraku should receive token: 'github-token'
]

{ #category : 'tests' }
AutoRenerakuTest >> testTonelSuggestionBuilderCompleteRemoval [

	| method data |
	method := self completeRemovalMethod.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	(autoreneraku suggestionBuilderFor: method) fillData: data.
	self assert: (data at: #body) equals: '```suggestion

```'.
	self
		assert: (data at: #path)
		equals:
		'src/AutoReneraku-Tests/AutoRenerakuTestSampleWithFlag.class.st'.
	self assert: (data at: #line) equals: 16.
	self deny: (data includesKey: #start_line)
]

{ #category : 'tests' }
AutoRenerakuTest >> testTonelSuggestionBuilderNotFirstMethodInTonel [

	| method data |
	method := self multiStatementRemovalMethod.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	(autoreneraku suggestionBuilderFor: method) fillData: data.
	self assert: (data at: #body) equals: '```suggestion

```'.
	self
		assert: (data at: #path)
		equals:
		'src/AutoReneraku-Tests/AutoRenerakuTestSampleWithFlag.class.st'.
	self assert: (data at: #line) equals: 30.
	self deny: (data includesKey: #start_line)
]

{ #category : 'tests' }
AutoRenerakuTest >> testTonelSuggestionBuilderProtocolOnlyChange [

	| method data |
	method := self protocolOnlyChangeMethod.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	(autoreneraku suggestionBuilderFor: method) fillData: data.
	self assert: (data at: #body) equals: '```suggestion
{ #category : ''tests'' }
```'.
	self
		assert: (data at: #path)
		equals:
		'src/AutoReneraku-Tests/AutoRenerakuTestSampleSubClass.class.st'.
	self assert: (data at: #line) equals: 12.
	self deny: (data includesKey: #start_line)
]
