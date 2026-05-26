"
Local fixture used by AutoRenerakuTest to exercise Renraku corrections and Tonel suggestions without depending on AutoReneraku-Sample.
"
Class {
	#name : 'AutoRenerakuTestSample',
	#superclass : 'Object',
	#category : 'AutoReneraku-Tests-Fixtures',
	#package : 'AutoReneraku-Tests',
	#tag : 'Fixtures'
}

{ #category : 'tests' }
AutoRenerakuTestSample >> testOutside [

	| outside |
	1 > 2
		ifTrue: [ outside := 3 ]
		ifFalse: [ outside := 4 ]
]
