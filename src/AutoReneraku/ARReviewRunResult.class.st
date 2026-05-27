"
I summarize one AutoReneraku review run. I keep track of methods that completed with a correction, methods ignored because there was nothing to apply, methods that raised an error, and suggestions that were built or posted.
"
Class {
	#name : 'ARReviewRunResult',
	#superclass : 'Object',
	#instVars : [
		'correctedMethods',
		'ignoredMethods',
		'erroredMethods',
		'postedSuggestions',
		'builtSuggestions',
		'methodErrors',
		'warnings'
	],
	#category : 'AutoReneraku',
	#package : 'AutoReneraku'
}

{ #category : 'accessing' }
ARReviewRunResult >> builtSuggestions [

	^ builtSuggestions asArray
]

{ #category : 'accessing' }
ARReviewRunResult >> correctedMethods [

	^ correctedMethods asArray
]

{ #category : 'accessing' }
ARReviewRunResult >> erroredMethods [

	^ erroredMethods asArray
]

{ #category : 'testing' }
ARReviewRunResult >> hasErrors [

	^ erroredMethods notEmpty
]

{ #category : 'testing' }
ARReviewRunResult >> hasWarnings [

	^ warnings notEmpty
]

{ #category : 'accessing' }
ARReviewRunResult >> ignoredMethods [

	^ ignoredMethods asArray
]

{ #category : 'initialization' }
ARReviewRunResult >> initialize [

	super initialize.
	correctedMethods := OrderedCollection new.
	ignoredMethods := OrderedCollection new.
	erroredMethods := OrderedCollection new.
	postedSuggestions := OrderedCollection new.
	builtSuggestions := OrderedCollection new.
	methodErrors := OrderedCollection new.
	warnings := OrderedCollection new
]

{ #category : 'testing' }
ARReviewRunResult >> isSuccessful [

	^ self hasErrors not
]

{ #category : 'accessing' }
ARReviewRunResult >> methodErrors [

	^ methodErrors asArray
]

{ #category : 'accessing' }
ARReviewRunResult >> postedSuggestions [

	^ postedSuggestions asArray
]

{ #category : 'recording' }
ARReviewRunResult >> recordCorrectedMethod: aMethod suggestion: aSuggestion [

	correctedMethods add: aMethod.
	builtSuggestions add: aSuggestion
]

{ #category : 'recording' }
ARReviewRunResult >> recordError: anError forMethod: aMethod [

	erroredMethods add: aMethod.
	methodErrors add: aMethod -> anError
]

{ #category : 'recording' }
ARReviewRunResult >> recordIgnoredMethod: aMethod [

	ignoredMethods add: aMethod
]

{ #category : 'recording' }
ARReviewRunResult >> recordPostedSuggestion: aSuggestion [

	postedSuggestions add: aSuggestion
]

{ #category : 'recording' }
ARReviewRunResult >> recordWarning: aString [

	warnings add: aString.
	(Stdio respondsTo: #stderr) ifTrue: [
			Stdio stderr
				<< aString;
				cr ].
	^ aString
]

{ #category : 'accessing' }
ARReviewRunResult >> warnings [

	^ warnings asArray
]
