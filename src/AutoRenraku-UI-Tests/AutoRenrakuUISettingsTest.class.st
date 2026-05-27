Class {
	#name : 'AutoRenrakuUISettingsTest',
	#superclass : 'TestCase',
	#instVars : [
		'defaultRepository',
		'lastPullRequestNumber',
		'openResultAfterRun'
	],
	#category : 'AutoRenraku-UI-Tests-Tests',
	#package : 'AutoRenraku-UI-Tests',
	#tag : 'Tests'
}

{ #category : 'running' }
AutoRenrakuUISettingsTest >> setUp [

	super setUp.
	defaultRepository := AutoRenrakuUISettings defaultRepository.
	lastPullRequestNumber := AutoRenrakuUISettings lastPullRequestNumber.
	openResultAfterRun := AutoRenrakuUISettings openResultAfterRun
]

{ #category : 'running' }
AutoRenrakuUISettingsTest >> tearDown [

	AutoRenrakuUISettings defaultRepository: defaultRepository.
	AutoRenrakuUISettings lastPullRequestNumber: lastPullRequestNumber.
	AutoRenrakuUISettings openResultAfterRun: openResultAfterRun.
	super tearDown
]

{ #category : 'tests' }
AutoRenrakuUISettingsTest >> testDefaultValues [

	AutoRenrakuUISettings defaultRepository: nil.
	AutoRenrakuUISettings lastPullRequestNumber: nil.
	AutoRenrakuUISettings openResultAfterRun: nil.

	self
		assert: AutoRenrakuUISettings defaultRepository
		equals: 'badetitou/AutoRenraku'.
	self assert: AutoRenrakuUISettings lastPullRequestNumber equals: ''.
	self assert: AutoRenrakuUISettings openResultAfterRun
]

{ #category : 'tests' }
AutoRenrakuUISettingsTest >> testSettingsCanRememberRepositoryAndPullRequestNumber [

	AutoRenrakuUISettings defaultRepository: 'owner/project'.
	AutoRenrakuUISettings lastPullRequestNumber: '77'.

	self
		assert: AutoRenrakuUISettings defaultRepository
		equals: 'owner/project'.
	self assert: AutoRenrakuUISettings lastPullRequestNumber equals: '77'
]

{ #category : 'tests' }
AutoRenrakuUISettingsTest >> testTokenIsNotStoredInSettings [

	self deny: (AutoRenrakuUISettings class includesSelector: #token).
	self deny: (AutoRenrakuUISettings class includesSelector: #token:)
]
