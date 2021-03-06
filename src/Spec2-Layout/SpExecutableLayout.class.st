Class {
	#name : #SpExecutableLayout,
	#superclass : #Object,
	#instVars : [
		'children',
		'selector',
		'adapter',
		'announcer'
	],
	#category : #'Spec2-Layout-Base'
}

{ #category : #private }
SpExecutableLayout >> adapterName [

	^ self subclassResponsibility
]

{ #category : #accessing }
SpExecutableLayout >> add: aName withConstraints: aBlock [
	| constraints |
	constraints := self constraintsClass new.
	aBlock value: constraints.
	children at: aName put: constraints
]

{ #category : #private }
SpExecutableLayout >> announceChildAdded: aChildPresenter [

	self presenter ifNotNil: [
		self announcer announce: (SpChildrenAdded new
			parent: self presenter;
			child: aChildPresenter;
			yourself)].
]

{ #category : #private }
SpExecutableLayout >> announceChildRemoved: aChildPresenter [

	self presenter ifNotNil: [
		self announcer announce: (SpChildrenRemoved new
			parent: self presenter;
			child: aChildPresenter;
			yourself)].
]

{ #category : #adding }
SpExecutableLayout >> announcer [

	^ announcer ifNil: [ announcer := Announcer new ]
]

{ #category : #converting }
SpExecutableLayout >> asArray [

	self error: 'Should not arrive here. This layout is executable then it will not be interpreted.'
]

{ #category : #converting }
SpExecutableLayout >> asSpLayout [
	
	^ self
]

{ #category : #building }
SpExecutableLayout >> buildAdapterFor: aPresenter bindings: bindings [

	adapter := (aPresenter needRebuild or: [ aPresenter adapter isNil ])
		ifTrue: [ 
			(bindings adapterClass: self adapterName) adapt: aPresenter ]
		ifFalse: [ 
			aPresenter adapter
				removeSubWidgets;
				yourself ].
			
	"Ensure we remove the flag `no need of rebuild` if it was set."
	aPresenter needRebuild: true.
	
	adapter layout: self.

	children keysAndValuesDo: [ :presenterNameOrLayout :constraints | 
		"Since a layout can be composed (by other layouts), we can include a 
		 presenter or a layout" 
		adapter 
			add: (self 
				resolvePresenter: presenterNameOrLayout 
				presenter: aPresenter 
				bindings: bindings) 
			constraints: constraints ].

	^ adapter
]

{ #category : #accessing }
SpExecutableLayout >> children [

	^ children keys
]

{ #category : #private }
SpExecutableLayout >> constraintsClass [

	^ self subclassResponsibility
]

{ #category : #accessing }
SpExecutableLayout >> constraintsFor: aPresenter [

	^ children at: aPresenter
]

{ #category : #accessing }
SpExecutableLayout >> deepPresenters [
	"answer all presenters in the layout hierarchy"
	
	^ self presenters
		inject: #()
		into: [ :all :each | 
			all, (each isSpLayout 
				ifTrue: [ each deepPresenters ]
				ifFalse: [ { each } ]) ]
]

{ #category : #initialization }
SpExecutableLayout >> initialize [ 

	super initialize.
	children := OrderedDictionary new
]

{ #category : #testing }
SpExecutableLayout >> isEmpty [

	^ children isEmpty
]

{ #category : #testing }
SpExecutableLayout >> isExecutable [

	^ true
]

{ #category : #testing }
SpExecutableLayout >> isSpLayout [

	^ true
]

{ #category : #accessing }
SpExecutableLayout >> parentLayoutOf: aKey [ 
	"Find a child layout that contains a presenter of given key. Useful if you need to find 
	 a parent layout of a presenter that you need to replace."

    (self children anySatisfy: [ :each | each = aKey ])
        ifTrue: [ ^ self ].
    
    self children do: [ :each | 
        each isSpLayout ifTrue: [ 
            | found | 
            found := each parentLayoutOf: aKey.
            found ifNotNil: [ ^ found ] ] ].
        
    ^ nil 
]

{ #category : #accessing }
SpExecutableLayout >> presenter [

	^ adapter ifNotNil: [ adapter presenter ]
]

{ #category : #accessing }
SpExecutableLayout >> presenters [
	
	^ children keys
]

{ #category : #removing }
SpExecutableLayout >> remove: aPresenter [

	self 
		remove: aPresenter 
		ifAbsent: [ self removeBySymbol: aPresenter ].
	self announceChildRemoved: aPresenter
]

{ #category : #private }
SpExecutableLayout >> remove: aPresenter ifAbsent: aBlock [

	^ (children includesKey: aPresenter)
		ifTrue: [ children removeKey: aPresenter ]
		ifFalse: aBlock
]

{ #category : #private }
SpExecutableLayout >> removeBySymbol: aPresenter [
	"I will look for the symbol that represents the presenter (in case of layouts defined by symbolic 
	 representation of presenter) and then I will remove it"

	children keys do: [ :each |
		each isPresenter ifFalse: [ 
			(adapter presenter presenterAt: each) = aPresenter ifTrue: [
				self remove: each ifAbsent: [ NotFound signal: 'Presenter not found.' ] ] ] ]
]

{ #category : #private }
SpExecutableLayout >> resolvePresenter: presenterNameOrLayout presenter: aPresenter bindings: bindings [

	"most common case: I receive a symbol that I need to convert into a presenter"
	presenterNameOrLayout isSymbol ifTrue: [ 
		^ (self subpresenterOrLayoutNamed: presenterNameOrLayout of: aPresenter)
			ifNil: [ self error: 'You presenter named "', presenterNameOrLayout , '" from ', aPresenter printString ,' was not initialized.' ] ].
	
	"I receive a layout: dig inside."
	presenterNameOrLayout isSpLayout ifTrue: [ 
		^ presenterNameOrLayout buildAdapterFor: aPresenter bindings: bindings ].
	
	"I receive an arbitrary object (needs to understand #asPresenter)"
	^ presenterNameOrLayout asPresenter
		owner: aPresenter;
		yourself
]

{ #category : #accessing }
SpExecutableLayout >> selector [
	^ selector
]

{ #category : #accessing }
SpExecutableLayout >> selector: anObject [
	selector := anObject
]

{ #category : #private }
SpExecutableLayout >> subpresenterOrLayoutNamed: presenterNameOrLayout of: aPresenter [

	^ aPresenter additionalSubpresentersMap
		at: presenterNameOrLayout
		ifAbsent: [ 
			aPresenter 
				presenterAt: presenterNameOrLayout 
				ifAbsent: [ 
					self error: 'No presenter named "' , presenterNameOrLayout , '" was found in ' , aPresenter printString ] ]
]

{ #category : #adding }
SpExecutableLayout >> whenChildrenAddedDo: aBlock [

	self announcer
		when: SpChildrenAdded
		do: aBlock
]

{ #category : #adding }
SpExecutableLayout >> whenChildrenRemovedDo: aBlock [

	self announcer
		when: SpChildrenRemoved
		do: aBlock
]

{ #category : #private }
SpExecutableLayout >> withAdapterDo: aValuable [
	"a convenience method to avoid verify by nil all the time"
	
	^ adapter ifNotNil: aValuable
]
