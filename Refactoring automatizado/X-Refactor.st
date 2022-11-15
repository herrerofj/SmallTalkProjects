!classDefinition: #XTest category: 'X-Refactor'!
RefactoringTest subclass: #XTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'X-Refactor'!

!XTest methodsFor: 'tests' stamp: 'FJH 10/25/2022 13:55:02'!
test01
	
	|class subclass selector refactorObject|
	
	class _ self createClassNamed: #RootClass.
	subclass _ self createClassNamed: #Subclass subclassOf: class.
	
	selector _ #m.
	
	subclass compile: selector, ' ^self '.
	
	refactorObject _ XMO for: class.
	refactorObject refactor.
	
	
	self assert:( class includesSelector: selector ).! !

!XTest methodsFor: 'tests' stamp: 'FJH 10/25/2022 13:55:14'!
test02
	
	|class subclass selector1 selector2 refactorObject |
	
	class _ self createClassNamed: #RootClass.
	subclass _ self createClassNamed: #Subclass subclassOf: class.
	
	selector1 _ #m1.
	selector2 _ #m2.
		
	subclass compile: selector1 asString; compile: selector2 asString.
	class compile: selector1 asString. 
	
	refactorObject _ XMO for: class.
	refactorObject refactor.
	
	self assert:( (class includesSelector: selector1) and: (class includesSelector: selector2) ).! !

!XTest methodsFor: 'tests' stamp: 'FJH 10/25/2022 13:55:29'!
test03
	
	|class subclass1 subclass2 selector1 selector2 refactorObject |
	
	class _ self createClassNamed: #RootClass.
	subclass1 _ self createClassNamed: #Subclass1 subclassOf: class.
	subclass2 _ self createClassNamed: #Subclass2 subclassOf: class.
	
	selector1 _ #m1.
	selector2 _ #m2.

	class compile: selector1 asString.
	
	subclass1 compile: selector1 asString.
	subclass2 compile: selector1 asString; compile: selector2 asString. 

	refactorObject _ XMO for: class.
	refactorObject refactor.
	
	self assert:(class includesSelector: selector1 ).
	self deny: (class includesSelector: selector2).! !

!XTest methodsFor: 'tests' stamp: 'FJH 10/25/2022 13:55:43'!
test04
	
	|class subclass1 subclass2 subclass3 selector refactorObject |
	
	class _ self createClassNamed: #RootClass.
	subclass1 _ self createClassNamed: #Subclass1 subclassOf: class.
	subclass2 _ self createClassNamed: #Subclass2 subclassOf: class.
	subclass3 _ self createClassNamed: #Subclass3 subclassOf: subclass2.
		
	selector _ #m1.
	
	subclass1 compile: selector asString.
	subclass3 compile: selector asString. 

	refactorObject _ XMO for: class.
	refactorObject refactor.
	
	self assert:( (class includesSelector: selector)).
	! !


!classDefinition: #XMO category: 'X-Refactor'!
Object subclass: #XMO
	instanceVariableNames: 'classToRefactor subclasses unsharedSelectors selectorsSubclasses selectorToCompile selectorsCandidates'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'X-Refactor'!

!XMO methodsFor: 'initialize' stamp: 'FJH 10/24/2022 15:20:45'!
initializeWith: aClassToRefactor 
	
	classToRefactor _ aClassToRefactor.
	
	subclasses _ classToRefactor subclasses asOrderedCollection .
	
	selectorsSubclasses _ OrderedCollection new.
	
	unsharedSelectors _ OrderedCollection new.
	
	selectorToCompile _ OrderedCollection new.

	selectorsCandidates _ Bag new.! !


!XMO methodsFor: 'compute -- private' stamp: 'FJH 10/24/2022 15:17:25'!
compileSelectors
	
	selectorToCompile do: [:selector | classToRefactor compile: selector value , ' self subclassResponsibility ' ]. 	
! !

!XMO methodsFor: 'compute -- private' stamp: 'FJH 10/25/2022 13:56:36'!
findSelectorsOfSubclasses
		
	subclasses do: [:subclass | selectorsSubclasses addAll: (XRecursion for: subclass) recursion ] .
	! !

!XMO methodsFor: 'compute -- private' stamp: 'FJH 10/24/2022 15:16:47'!
selectCandidatesToCompile
	
	selectorsCandidates _ unsharedSelectors asBag.
		
	selectorsCandidates 		sortedCounts 
		select: [:assoc | (assoc key isEqualTo: subclasses size ) 			]	 
		thenDo: [:assoc | selectorToCompile add: assoc value].! !

!XMO methodsFor: 'compute -- private' stamp: 'FJH 10/24/2022 15:02:14'!
selectSubclassSelectorsAreNotInClassSelectors
	
	unsharedSelectors _ 	selectorsSubclasses 		reject: [:selector | 		classToRefactor canUnderstand: selector].
	
	! !


!XMO methodsFor: 'compute' stamp: 'FJH 10/25/2022 13:55:58'!
refactor
	
	self findSelectorsOfSubclasses .
	
	self selectSubclassSelectorsAreNotInClassSelectors.
	
	self selectCandidatesToCompile.
	
	self compileSelectors.
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'XMO class' category: 'X-Refactor'!
XMO class
	instanceVariableNames: ''!

!XMO class methodsFor: 'as yet unclassified' stamp: 'FJH 10/25/2022 13:54:25'!
for: aClassToRefactor
	
	^ self new initializeWith: aClassToRefactor .
	! !


!classDefinition: #XRecursion category: 'X-Refactor'!
Object subclass: #XRecursion
	instanceVariableNames: 'classToRecursion subclasses selectorsSubclasses unsharedSelectors'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'X-Refactor'!

!XRecursion methodsFor: 'compute' stamp: 'FJH 10/25/2022 13:56:25'!
recursion
	
	self findSelectorsOfSubclasses.
		
	self selectSubclassSelectorsAreNotInClassSelectors.
	
	self addUnsharedSelectorToClassSelectors. 
	
	^ unsharedSelectors .! !


!XRecursion methodsFor: 'compute -- private' stamp: 'FJH 10/24/2022 15:22:48'!
addUnsharedSelectorToClassSelectors
	
	unsharedSelectors addAll: classToRecursion selectors.! !

!XRecursion methodsFor: 'compute -- private' stamp: 'FJH 10/25/2022 13:56:19'!
findSelectorsOfSubclasses
		
	subclasses do: [:subclass | selectorsSubclasses addAll: (XRecursion for: subclass) recursion ] .
	! !

!XRecursion methodsFor: 'compute -- private' stamp: 'FJH 10/24/2022 14:56:53'!
selectSubclassSelectorsAreNotInClassSelectors
	
	
	unsharedSelectors _ 	selectorsSubclasses 		reject: [:selector | 		classToRecursion canUnderstand: selector].
	
	! !


!XRecursion methodsFor: 'initialize' stamp: 'FJH 10/24/2022 15:23:08'!
initializeWith: aClassToRecursion 
	
	classToRecursion _ aClassToRecursion .
	
	subclasses _ classToRecursion subclasses asOrderedCollection .
	
	selectorsSubclasses _ OrderedCollection new.
	
	unsharedSelectors _ OrderedCollection new. 
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'XRecursion class' category: 'X-Refactor'!
XRecursion class
	instanceVariableNames: ''!

!XRecursion class methodsFor: 'as yet unclassified' stamp: 'FJH 10/25/2022 13:57:27'!
for: aClassToRefactor
	
	^ self new initializeWith: aClassToRefactor .
	! !
