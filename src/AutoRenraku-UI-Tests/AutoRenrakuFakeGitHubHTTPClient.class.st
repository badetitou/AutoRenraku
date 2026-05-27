Class {
	#name : 'AutoRenrakuFakeGitHubHTTPClient',
	#superclass : 'Object',
	#instVars : [
		'responses',
		'currentUrl',
		'requestedUrls',
		'headers'
	],
	#category : 'AutoRenraku-UI-Tests-Fixtures',
	#package : 'AutoRenraku-UI-Tests',
	#tag : 'Fixtures'
}

{ #category : 'operations' }
AutoRenrakuFakeGitHubHTTPClient >> get [

	^ responses
		  at: currentUrl
		  ifAbsent: [ self error: 'No fake response for ' , currentUrl ]
]

{ #category : 'accessing' }
AutoRenrakuFakeGitHubHTTPClient >> headerAt: aKey [

	^ headers at: aKey ifAbsent: [ nil ]
]

{ #category : 'accessing' }
AutoRenrakuFakeGitHubHTTPClient >> headerAt: aKey put: aValue [

	headers at: aKey put: aValue
]

{ #category : 'initialization' }
AutoRenrakuFakeGitHubHTTPClient >> initialize [

	super initialize.
	responses := Dictionary new.
	requestedUrls := OrderedCollection new.
	headers := Dictionary new
]

{ #category : 'accessing' }
AutoRenrakuFakeGitHubHTTPClient >> requestedUrls [

	^ requestedUrls asArray
]

{ #category : 'testing support' }
AutoRenrakuFakeGitHubHTTPClient >> responseAt: aUrl put: aResponse [

	responses at: aUrl put: aResponse
]

{ #category : 'accessing' }
AutoRenrakuFakeGitHubHTTPClient >> url: aUrl [

	currentUrl := aUrl.
	requestedUrls add: aUrl
]
