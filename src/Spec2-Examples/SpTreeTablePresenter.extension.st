Extension { #name : #SpTreeTablePresenter }

{ #category : #'*Spec2-Examples' }
SpTreeTablePresenter class >> example [

	^ self new
		addColumn: (SpCompositeTableColumn new
			title: 'Classes';
			addColumn: ((SpImageTableColumn evaluated: #systemIcon) width: 20);
			addColumn: (SpStringTableColumn evaluated: #name);
			yourself);
		roots: { Object };
		children: [ :aClass | aClass subclasses ];
		openWithSpec
]

{ #category : #'*Spec2-Examples' }
SpTreeTablePresenter class >> exampleExpandPath [

	^ self new
		addColumn: (SpCompositeTableColumn new
			title: 'Classes';
			addColumn: ((SpImageTableColumn evaluated: #systemIcon) width: 20);
			addColumn: (SpStringTableColumn evaluated: #name);
			yourself);
		roots: { Object };
		children: [ :aClass | aClass subclasses ];
		expandPath: #(1 1 3); "Object/Exception/Notification"
		openWithSpec
]

{ #category : #'*Spec2-Examples' }
SpTreeTablePresenter class >> exampleExpandRoots [

	^ self new
		addColumn: (SpCompositeTableColumn new
			title: 'Classes';
			addColumn: ((SpImageTableColumn evaluated: #systemIcon) width: 20);
			addColumn: (SpStringTableColumn evaluated: #name);
			yourself);
		roots: { Object };
		children: [ :aClass | aClass subclasses ];
		expandRoots;
		openWithSpec
]
