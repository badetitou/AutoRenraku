"
Builds GitHub Tonel suggestions for a method corrected in the image.
"
Class {
	#name : 'ARTonelSuggestionBuilder',
	#superclass : 'Object',
	#instVars : [
		'originalMethod',
		'originalDefinition'
	],
	#category : 'AutoReneraku',
	#package : 'AutoReneraku'
}

{ #category : 'instance creation' }
ARTonelSuggestionBuilder class >> forOriginalMethod: aCompiledMethod [

	^ self new
		  originalMethod: aCompiledMethod;
		  yourself
]

{ #category : 'accessing' }
ARTonelSuggestionBuilder >> body [

	| changedLines start stop |
	start := self diffStartOffset.
	stop := self diffStopOffset.
	changedLines := stop = 0
		                ifTrue: [ #(  ) ]
		                ifFalse: [
		                self correctedTonelLines
			                copyFrom: start
			                to: start + stop - 1 ].
	^ (String streamContents: [ :stream |
			   stream << '```suggestion'.
			   stream << String cr.
			   stream << (String cr join: changedLines).
			   stream << String cr.
			   stream << '```' ])
		  copyReplaceAll: OSPlatform current lineEnding
		  with: String cr
]

{ #category : 'private' }
ARTonelSuggestionBuilder >> comparableTonelFrom: aTonelDefinition [

	^ String cr join: (self tonelLinesOfDefinition: aTonelDefinition)
]

{ #category : 'private' }
ARTonelSuggestionBuilder >> correctedComparableTonel [

	^ self comparableTonelFrom: self correctedDefinition
]

{ #category : 'accessing' }
ARTonelSuggestionBuilder >> correctedDefinition [

	^ self tonelDefinitionOf: self correctedMethod
]

{ #category : 'accessing' }
ARTonelSuggestionBuilder >> correctedMethod [

	^ originalMethod methodClass >> originalMethod selector
]

{ #category : 'private' }
ARTonelSuggestionBuilder >> correctedTonelLines [

	^ self tonelLinesOfDefinition: self correctedDefinition
]

{ #category : 'accessing' }
ARTonelSuggestionBuilder >> diffStartOffset [

	^ self differences findFirst: [ :diff | diff key ~= 'match' ]
]

{ #category : 'accessing' }
ARTonelSuggestionBuilder >> diffStopOffset [

	| insert remove differences |
	differences := self differences.
	insert := differences count: [ :diff | diff key = 'insert' ].
	remove := differences count: [ :diff | diff key = 'remove' ].
	^ remove min: insert
]

{ #category : 'accessing' }
ARTonelSuggestionBuilder >> differences [

	^ (DiffMorph
		   from: self originalComparableTonel
		   to: self correctedComparableTonel) difference
]

{ #category : 'accessing' }
ARTonelSuggestionBuilder >> fillData: aDictionary [

	aDictionary at: #body put: self body.
	aDictionary at: #path put: self path.
	aDictionary at: #start_line put: self startLine.
	aDictionary at: #line put: self line.

	(aDictionary at: #start_line) >= (aDictionary at: #line) ifTrue: [
			aDictionary at: #line put: (aDictionary at: #start_line).
			aDictionary removeKey: #start_line ].

	^ aDictionary
]

{ #category : 'accessing' }
ARTonelSuggestionBuilder >> line [

	| line |
	line := self startLine.
	self diffStopOffset ~= 0 ifTrue: [
		line := line + self diffStopOffset - 1 ].
	^ line
]

{ #category : 'private' }
ARTonelSuggestionBuilder >> methodDeclaration [

	| methodDefinition classDefinition writer |
	methodDefinition := self correctedMethod basicAsMCMethodDefinition.
	classDefinition := self correctedMethod methodClass asClassDefinition.
	writer := TonelWriter new.
	^ String streamContents: [ :stream |
			  | fullClassName |
			  fullClassName := writer
				                   classNameFor: methodDefinition
				                   parent: classDefinition.
			  writer
				  splitMethodSource: methodDefinition
				  into: [ :methodDeclaration :methodBody |
					  stream << fullClassName << ' >> ' << methodDeclaration ] ]
]

{ #category : 'private' }
ARTonelSuggestionBuilder >> methodDeclarationLine [

	^ ((TonelWriter sourceCodeOf: self correctedMethod methodClass)
		   arToLineCharacter: self methodStartCharacter) at: #line
]

{ #category : 'accessing' }
ARTonelSuggestionBuilder >> methodStartCharacter [

	^ (TonelWriter sourceCodeOf: self correctedMethod methodClass)
		  findString: self methodDeclaration
]

{ #category : 'private' }
ARTonelSuggestionBuilder >> originalComparableTonel [

	^ self comparableTonelFrom: self originalDefinition
]

{ #category : 'accessing' }
ARTonelSuggestionBuilder >> originalDefinition [

	^ originalDefinition
]

{ #category : 'accessing' }
ARTonelSuggestionBuilder >> originalMethod [

	^ originalMethod
]

{ #category : 'initialization' }
ARTonelSuggestionBuilder >> originalMethod: aCompiledMethod [

	originalMethod := aCompiledMethod.
	originalDefinition := self tonelDefinitionOf: aCompiledMethod
]

{ #category : 'accessing' }
ARTonelSuggestionBuilder >> path [

	^ String streamContents: [ :stream |
			  stream << 'src/'.
			  stream << originalMethod methodClass package name.
			  stream << '/'.
			  stream << originalMethod methodClass name.
			  stream << '.class.st' ]
]

{ #category : 'accessing' }
ARTonelSuggestionBuilder >> startLine [

	^ self methodDeclarationLine + self diffStartOffset - 1
]

{ #category : 'private' }
ARTonelSuggestionBuilder >> tonelDefinitionOf: aCompiledMethod [

	^ String streamContents: [ :stream |
			  TonelWriter new
				  writeMethodDefinition: aCompiledMethod basicAsMCMethodDefinition
				  parent: aCompiledMethod methodClass asClassDefinition
				  on: stream ]
]

{ #category : 'private' }
ARTonelSuggestionBuilder >> tonelLinesOfDefinition: aString [

	^ aString lines allButFirst
]
