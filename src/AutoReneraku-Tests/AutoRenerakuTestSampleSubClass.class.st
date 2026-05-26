"
Local fixture whose test method starts in a non-test protocol so Renraku can propose a protocol-only Tonel change.
"
Class {
	#name : 'AutoRenerakuTestSampleSubClass',
	#superclass : 'AutoRenerakuTestSample',
	#category : 'AutoReneraku-Tests-Fixtures',
	#package : 'AutoReneraku-Tests',
	#tag : 'Fixtures'
}

{ #category : 'execution' }
AutoRenerakuTestSampleSubClass >> testOutside [

	| outside |
	outside := 1 > 2
		           ifTrue: [ 3 ]
		           ifFalse: [ 4 ]
]
