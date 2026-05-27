"
I am the Spec application used to open the AutoRenraku pull request review tool from a Pharo image.
"
Class {
	#name : 'AutoRenrakuUIApplication',
	#superclass : 'SpApplication',
	#category : 'AutoRenraku-UI-UI',
	#package : 'AutoRenraku-UI',
	#tag : 'UI'
}

{ #category : 'instance creation' }
AutoRenrakuUIApplication class >> open [

	<script>
	^ self new start
]

{ #category : 'running' }
AutoRenrakuUIApplication >> start [

	^ AutoRenrakuPullRequestReviewPresenter new
		  application: self;
		  open
]
