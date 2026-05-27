"
I hold AutoRenraku UI settings. I intentionally do not store GitHub tokens.
"
Class {
	#name : 'AutoRenrakuUISettings',
	#superclass : 'Object',
	#classInstVars : [
		'defaultRepository',
		'lastPullRequestNumber',
		'openResultAfterRun'
	],
	#category : 'AutoRenraku-UI-Settings',
	#package : 'AutoRenraku-UI',
	#tag : 'Settings'
}

{ #category : 'accessing' }
AutoRenrakuUISettings class >> defaultRepository [

	^ defaultRepository ifNil: [
		  defaultRepository := self defaultRepositoryDefaultValue ]
]

{ #category : 'accessing' }
AutoRenrakuUISettings class >> defaultRepository: aString [

	defaultRepository := aString
]

{ #category : 'defaults' }
AutoRenrakuUISettings class >> defaultRepositoryDefaultValue [

	^ 'badetitou/AutoRenraku'
]

{ #category : 'accessing' }
AutoRenrakuUISettings class >> lastPullRequestNumber [

	^ lastPullRequestNumber ifNil: [
		  lastPullRequestNumber := self lastPullRequestNumberDefaultValue ]
]

{ #category : 'accessing' }
AutoRenrakuUISettings class >> lastPullRequestNumber: aString [

	lastPullRequestNumber := aString
]

{ #category : 'defaults' }
AutoRenrakuUISettings class >> lastPullRequestNumberDefaultValue [

	^ ''
]

{ #category : 'accessing' }
AutoRenrakuUISettings class >> openResultAfterRun [

	^ openResultAfterRun ifNil: [
		  openResultAfterRun := self openResultAfterRunDefaultValue ]
]

{ #category : 'accessing' }
AutoRenrakuUISettings class >> openResultAfterRun: aBoolean [

	openResultAfterRun := aBoolean
]

{ #category : 'defaults' }
AutoRenrakuUISettings class >> openResultAfterRunDefaultValue [

	^ true
]

{ #category : 'settings' }
AutoRenrakuUISettings class >> settingsOn: aBuilder [

	<systemsettings>
	(aBuilder group: #AutoRenraku)
		parent: #tools;
		label: 'AutoRenraku';
		description: 'Settings for the AutoRenraku pull request review UI';
		with: [
				(aBuilder setting: #defaultRepository)
					target: self;
					default: self defaultRepositoryDefaultValue;
					label: 'Default repository';
					description:
						'Default GitHub repository, formatted as owner/name.'.
				(aBuilder setting: #lastPullRequestNumber)
					target: self;
					default: self lastPullRequestNumberDefaultValue;
					label: 'Last pull request number';
					description:
						'Last pull request number entered in the AutoRenraku UI.'.
				(aBuilder setting: #openResultAfterRun)
					target: self;
					default: self openResultAfterRunDefaultValue;
					label: 'Open result after run';
					description:
						'Open or refresh the result panel after running AutoRenraku.' ]
]
