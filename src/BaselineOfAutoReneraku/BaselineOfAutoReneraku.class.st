Class {
	#name : 'BaselineOfAutoReneraku',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfAutoReneraku',
	#package : 'BaselineOfAutoReneraku'
}

{ #category : 'baselines' }
BaselineOfAutoReneraku >> baseline: spec [

	<baseline>
	spec for: #common do: [
		self defineDependencies: spec.

		self definePackages: spec.

		self defineGroups: spec ]
]

{ #category : 'baselines' }
BaselineOfAutoReneraku >> defineDependencies: spec [

	spec
		baseline: 'Mocketry'
		with: [ spec repository: 'github://dionisiydk/Mocketry:master' ]
]

{ #category : 'baselines' }
BaselineOfAutoReneraku >> defineGroups: spec [

	spec group: 'core' with: #( 'AutoReneraku' ).
	spec group: 'ui' with: #( 'AutoRenraku-UI' ).
	spec
		group: 'tests'
		with: #( 'AutoReneraku-Tests' 'AutoRenraku-UI-Tests' ).
	spec group: 'default' with: #( 'core' )
]

{ #category : 'baselines' }
BaselineOfAutoReneraku >> definePackages: spec [

	spec package: 'AutoReneraku'.
	spec
		package: 'AutoRenraku-UI'
		with: [ spec requires: #( 'AutoReneraku' ) ].
	spec
		package: 'AutoReneraku-Tests'
		with: [ spec requires: #( 'AutoReneraku' 'Mocketry' ) ].
	spec package: 'AutoRenraku-UI-Tests' with: [
			spec requires:
				#( 'AutoRenraku-UI' 'AutoReneraku-Tests' 'Mocketry' ) ]
]
