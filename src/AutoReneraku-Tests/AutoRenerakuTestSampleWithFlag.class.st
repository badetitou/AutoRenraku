"
Local fixture containing flag critiques used to test complete Tonel method removals.
"
Class {
	#name : 'AutoRenerakuTestSampleWithFlag',
	#superclass : 'AutoRenerakuTestSample',
	#category : 'AutoReneraku-Tests-Fixtures',
	#package : 'AutoReneraku-Tests',
	#tag : 'Fixtures'
}

{ #category : 'tests' }
AutoRenerakuTestSampleWithFlag >> testOutside [

	| outside |
	self flag: 'We should improve this method'.
	outside := 1 > 2
		           ifTrue: [ 3 ]
		           ifFalse: [ 4 ]
]

{ #category : 'tests' }
AutoRenerakuTestSampleWithFlag >> testOutsideMultiStatementFlag [
	"with comment"

	| outside |
	outside := 1 > 2
		           ifTrue: [ 3 ]
		           ifFalse: [ 4 ].
	self flag: 'We should improve this method'.
	outside := 1 > 2
		           ifTrue: [ 3 ]
		           ifFalse: [ 4 ]
]

{ #category : 'tests' }
AutoRenerakuTestSampleWithFlag >> testOutsideMultiStatementFlagNotFormatted [
	"with comment"

	| outside |
	outside := 1 > 2 ifTrue: [ 3 ] ifFalse: [ 4 ].
	self flag: 'We should improve this method'.
	outside := 1 > 2 ifTrue: [ 3 ] ifFalse: [ 4 ]
]
