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

{ #category : 'running' }
AutoRenerakuTest >> setUp [

	super setUp.

	autoreneraku := AutoReneraku new.
	autoreneraku projectName: 'AutoReneraku-Sample'
]

{ #category : 'running' }
AutoRenerakuTest >> tearDown [

	| registry |
	registry := IceRepository registry detect: [ :r |
		            r name = 'AutoReneraku-Sample' ].
	registry loadedPackages do: [ :package |
		package
			unload;
			load ].
	super tearDown
]

{ #category : 'tests' }
AutoRenerakuTest >> testAutoRenerakuMethodSkipsNotFormattedSuggestion [

	| method |
	method := ARSampleWithFlag
	          >> #testOutsideMultiStatementFlagNotFormatted.
	(autoreneraku stub suggestNewMethod: Any) willReturn: true.
	autoreneraku autoRenerakuMethod: method.
	autoreneraku should not receive suggestNewMethod: Any
]

{ #category : 'tests' }
AutoRenerakuTest >> testBuildBodyOfBasedOn [

	| method data |
	method := ARSample >> #testOutside.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	(autoreneraku buildBodyOf: data basedOn: method).
	self assert: (data at: #body) equals: '```suggestion
	outside := 1 > 2
		           ifTrue: [ 3 ]
		           ifFalse: [ 4 ]
```'
]

{ #category : 'tests' }
AutoRenerakuTest >> testBuildBodyOfBasedOnForProtocol [

	| method data |
	method := ARSampleSubClass >> #testOutside.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	(autoreneraku buildBodyOf: data basedOn: method).
	self assert: (data at: #body) equals: '```suggestion
{ #category : ''tests'' }
```'
]

{ #category : 'tests' }
AutoRenerakuTest >> testBuildBodyOfBasedOnForRemoval [

	| method data |
	method := ARSampleWithFlag >> #testOutside.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	(autoreneraku buildBodyOf: data basedOn: method).
	"At least it should be removed (and replace with nothing, why not?)"
	self assert: (data at: #body) equals: '```suggestion

```'
]

{ #category : 'tests' }
AutoRenerakuTest >> testBuildBodyOfBasedOnForRemovalMultiStatement [

	| method data |
	method := ARSampleWithFlag >> #testOutsideMultiStatementFlag.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	(autoreneraku buildBodyOf: data basedOn: method).
	"At least it should be removed (and replace with nothing, why not?)"
	self assert: (data at: #body) equals: '```suggestion

```'
]

{ #category : 'tests' }
AutoRenerakuTest >> testBuildLineOfBasedOn [

		| method data |
	method := ARSample >> #testOutside.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	(autoreneraku buildLineOf: data basedOn: method).
	self assert: (data at: #line) equals: 14
]

{ #category : 'tests' }
AutoRenerakuTest >> testBuildStartLineOfBasedOn [

		| method data |
	method := ARSample >> #testOutside.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	(autoreneraku buildStartLineOf: data basedOn: method).
	self assert: (data at: #start_line) equals: 12
]

{ #category : 'tests' }
AutoRenerakuTest >> testComputeDiffStartOffsetFor [

	| method |
	method := ARSample >> #testOutside.
	autoreneraku autoCorrectMethod: method.
	self assert:  (autoreneraku computeDiffStartOffsetFor: method) equals: 5.
]

{ #category : 'tests' }
AutoRenerakuTest >> testComputeDiffStartOffsetForProtocolUpdate [

	| method |
	method := ARSampleSubClass >> #testOutside.
	autoreneraku autoCorrectMethod: method.
	self assert:  (autoreneraku computeDiffStartOffsetFor: method) equals: 1.
]

{ #category : 'tests' }
AutoRenerakuTest >> testComputeDiffStartOffsetForRemoval [

	| method |
	method := ARSampleWithFlag >> #testOutside.
	autoreneraku autoCorrectMethod: method.
	self assert:  (autoreneraku computeDiffStartOffsetFor: method) equals: 5.
]

{ #category : 'tests' }
AutoRenerakuTest >> testComputeDiffStopOffsetFor [

	| method |
	method := ARSample >> #testOutside.
	autoreneraku autoCorrectMethod: method.
	self assert:  (autoreneraku computeDiffStopOffsetFor: method) equals: 3.
]

{ #category : 'tests' }
AutoRenerakuTest >> testComputeDiffStopOffsetForProtocolUpdate [

	| method |
	method := ARSampleSubClass >> #testOutside.
	autoreneraku autoCorrectMethod: method.
	self assert:  (autoreneraku computeDiffStopOffsetFor: method) equals: 1.
]

{ #category : 'tests' }
AutoRenerakuTest >> testComputeDiffStopOffsetForRemoval [

	| method |
	method := ARSampleWithFlag >> #testOutside.
	autoreneraku autoCorrectMethod: method.
	self assert:  (autoreneraku computeDiffStopOffsetFor: method) equals: 0.
]

{ #category : 'tests' }
AutoRenerakuTest >> testDiffStartOutsideMultiStatementFlag [

	| method |
	method := ARSampleWithFlag >> #testOutsideMultiStatementFlag.
	autoreneraku autoCorrectMethod: method.
	self assert:  (autoreneraku computeDiffStartOffsetFor: method) equals: 9.
]

{ #category : 'tests' }
AutoRenerakuTest >> testDiffStopOutsideMultiStatementFlag [

	| method |
	method := ARSampleWithFlag >> #testOutsideMultiStatementFlag.
	autoreneraku autoCorrectMethod: method.
	self assert:  (autoreneraku computeDiffStopOffsetFor: method) equals: 0
]

{ #category : 'tests' }
AutoRenerakuTest >> testFillDataWithNewMethodData [

	| method data |
	method := ARSample >> #testOutside.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	autoreneraku fillData: data withNewMethodData: method.
	self assert: data size equals: 4
]

{ #category : 'tests' }
AutoRenerakuTest >> testFillDataWithNewMethodDataWhenOneLineUpdate [

	| method data |
	method := ARSampleSubClass >> #testOutside.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	autoreneraku fillData: data withNewMethodData: method.
	self assert: data size equals: 3
]

{ #category : 'tests' }
AutoRenerakuTest >> testFillDataWithNewMethodDataWhenRemove [

	| method data |
	method := ARSampleWithFlag >> #testOutside.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	autoreneraku fillData: data withNewMethodData: method.
	self assert: data size equals: 3
]

{ #category : 'tests' }
AutoRenerakuTest >> testNotFirstMethodInTonel [

	| method2 data |

	(autoreneraku stub suggestNewMethod: Any) willReturn: true.

	autoreneraku autoRenerakuMethod: ARSampleWithFlag >> #testOutside.
	autoreneraku autoRenerakuMethod: ARSampleWithFlag >> #testOutsideMultiStatementFlagNotFormatted.

	method2 := ARSampleWithFlag >> #testOutsideMultiStatementFlag.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method2.
	autoreneraku buildLineOf: data basedOn: method2.
	self assert: (data at: #line) equals: 26
]

{ #category : 'tests' }
AutoRenerakuTest >> testNotFormattedDoNothing [

	| method |
	method := ARSampleWithFlag
	          >> #testOutsideMultiStatementFlagNotFormatted.
	self deny: (autoreneraku isMethodFormatted: method).
	self deny: (autoreneraku autoCorrectMethod: method)
]

{ #category : 'tests' }
AutoRenerakuTest >> testTonelSuggestionBuilderCompleteRemoval [

	| method data |
	method := ARSampleWithFlag >> #testOutside.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	(autoreneraku suggestionBuilderFor: method) fillData: data.
	self assert: (data at: #body) equals: '```suggestion

```'.
	self
		assert: (data at: #path)
		equals: 'src/AutoReneraku-Sample/ARSampleWithFlag.class.st'.
	self assert: (data at: #line) equals: 12.
	self deny: (data includesKey: #start_line)
]

{ #category : 'tests' }
AutoRenerakuTest >> testTonelSuggestionBuilderNotFirstMethodInTonel [

	| method data |
	method := ARSampleWithFlag >> #testOutsideMultiStatementFlag.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	(autoreneraku suggestionBuilderFor: method) fillData: data.
	self assert: (data at: #body) equals: '```suggestion

```'.
	self
		assert: (data at: #path)
		equals: 'src/AutoReneraku-Sample/ARSampleWithFlag.class.st'.
	self assert: (data at: #line) equals: 26.
	self deny: (data includesKey: #start_line)
]

{ #category : 'tests' }
AutoRenerakuTest >> testTonelSuggestionBuilderProtocolOnlyChange [

	| method data |
	method := ARSampleSubClass >> #testOutside.
	data := Dictionary new.
	autoreneraku autoCorrectMethod: method.
	(autoreneraku suggestionBuilderFor: method) fillData: data.
	self assert: (data at: #body) equals: '```suggestion
{ #category : ''tests'' }
```'.
	self
		assert: (data at: #path)
		equals: 'src/AutoReneraku-Sample/ARSampleSubClass.class.st'.
	self assert: (data at: #line) equals: 8.
	self deny: (data includesKey: #start_line)
]
