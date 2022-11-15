!classDefinition: #XTest category: 'X'!
RefactoringTest subclass: #XTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'X'!

!XTest methodsFor: 'as yet unclassified' stamp: 'FJH 10/23/2022 16:09:53'!
test01
	
	|class subclass selector|
	
	class _ self createClassNamed: #RootClass.
	subclass _ self createClassNamed: #Subclass subclassOf: class.
	
	selector _ #m.
	
	subclass compile: selector, ' ^self '.
	
	"X for: class."
	"XRecursion for: class."
	XMO for: class.
	
	self assert:( class includesSelector: selector ).! !

!XTest methodsFor: 'as yet unclassified' stamp: 'FJH 10/23/2022 16:13:49'!
test02
	
	|class subclass selector1 selector2 selector3|
	
	class _ self createClassNamed: #RootClass.
	subclass _ self createClassNamed: #Subclass subclassOf: class.
	
	selector1 _ #m1.
	selector2 _ #m2.
	selector3 _ #m3.
		
	subclass compile: selector1 asString; compile: selector2 asString ; compile: selector3 asString.
	class compile: selector1 asString. 
	
	XMO for: class.
	
	self assert:( (class includesSelector: selector1) and: (class includesSelector: selector2) and: (class includesSelector: selector3) ).! !

!XTest methodsFor: 'as yet unclassified' stamp: 'FJH 10/23/2022 16:14:01'!
test03
	
	|class subclass1 subclass2 selector1 selector2 selector3|
	
	class _ self createClassNamed: #RootClass.
	subclass1 _ self createClassNamed: #Subclass1 subclassOf: class.
	subclass2 _ self createClassNamed: #Subclass2 subclassOf: class.
	
	selector1 _ #m1.
	selector2 _ #m2.
	selector3 _ #m3.
	
	class compile: selector2 asString.
	
	subclass1 compile: selector1 asString; compile: selector3 asString.
	subclass2 compile: selector1 asString; compile: selector2 asString. 

	XMO for: class.
	
	self assert:( (class includesSelector: selector1) and: (class includesSelector: selector2)).
	self deny: (class includesSelector: selector3).! !

!XTest methodsFor: 'as yet unclassified' stamp: 'FJH 10/23/2022 16:14:36'!
test04
	
	|class subclass1 subclass2 subclass3 selector |
	
	class _ self createClassNamed: #RootClass.
	subclass1 _ self createClassNamed: #Subclass1 subclassOf: class.
	subclass2 _ self createClassNamed: #Subclass2 subclassOf: class.
	subclass3 _ self createClassNamed: #Subclass3 subclassOf: subclass2.
		
	selector _ #m1.
	
	subclass1 compile: selector asString.
	subclass3 compile: selector asString. 

	XMO for: class.
	
	self assert:( (class includesSelector: selector)).
	! !


!classDefinition: #YTest category: 'X'!
TestCase subclass: #YTest
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'X'!

!YTest methodsFor: 'as yet unclassified' stamp: 'FJH 10/24/2022 14:47:44'!
test01
	
	| selector |
	
	selector _ #n.
	
	self deny: (Y includesSelector: selector ).
	
	XMO for: Y.	
	
	self assert: (Y includesSelector: selector ).! !


!classDefinition: #X category: 'X'!
Object subclass: #X
	instanceVariableNames: 'classToRefactor subclasses subclassesSelectors unsharedSelectors selectorsToAdd'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'X'!

!X methodsFor: 'initialize' stamp: 'FJH 10/23/2022 14:37:25'!
initializeWith: aClassToRefactor 
	
	classToRefactor _ aClassToRefactor.
	
	subclasses _ OrderedCollection new.
	
	subclassesSelectors _ OrderedCollection new.
	
	unsharedSelectors _ OrderedCollection new.
	
	selectorsToAdd _ OrderedCollection new.
! !


!X methodsFor: 'compute' stamp: 'FJH 10/23/2022 14:24:18'!
compileSelectorsInClassToRefactor

	self compileSelectors .
! !

!X methodsFor: 'compute' stamp: 'FJH 10/23/2022 14:36:01'!
findSelectorsOfClassToRefactor
	
	self obtainSelectorsOfSubclasses .
! !

!X methodsFor: 'compute' stamp: 'FJH 10/23/2022 14:13:55'!
findSubclassesOfClassToRefactor
	
	subclasses _ classToRefactor subclasses.! !

!X methodsFor: 'compute' stamp: 'FJH 10/23/2022 14:13:27'!
m
	
	self findSubclassesOfClassToRefactor.

	self findSelectorsOfClassToRefactor.
	
	self selectUnsharedSelectorsBettewSubclassesAndClassToRefactor.

	self selectSelectorsToCompileInClassToRefactor.
	
	self compileSelectorsInClassToRefactor! !

!X methodsFor: 'compute' stamp: 'FJH 10/23/2022 14:39:11'!
selectSelectorsToCompileInClassToRefactor
	
	self selectUnsharedSelectorsToCompile.
			! !

!X methodsFor: 'compute' stamp: 'FJH 10/23/2022 14:39:15'!
selectUnsharedSelectorsBettewSubclassesAndClassToRefactor
	
	self selectUnsharedSelectors .! !


!X methodsFor: 'compile - private' stamp: 'FJH 10/23/2022 14:24:05'!
compileSelectors
		
	selectorsToAdd do: [:selector | classToRefactor compile: selector value , ' self subclassResponsibility ' ]. 
! !

!X methodsFor: 'compile - private' stamp: 'FJH 10/23/2022 14:36:33'!
obtainSelectorsOfSubclasses
	
	subclasses do: [:subclass | subclassesSelectors add: subclass selectors ] .
	! !

!X methodsFor: 'compile - private' stamp: 'FJH 10/23/2022 14:36:38'!
selectUnsharedSelectors
	
	| classToRefactorSelectors |
	
	classToRefactorSelectors _ classToRefactor selectors.

	subclassesSelectors 
		do:[:subclassSelectors | 
			unsharedSelectors add:
				(subclassSelectors reject: [:selector | classToRefactorSelectors includes: selector])
		].
! !

!X methodsFor: 'compile - private' stamp: 'FJH 10/23/2022 14:36:51'!
selectUnsharedSelectorsToCompile
	
	| selectorsCandidates |
	
	selectorsCandidates _ Bag new.
		
	unsharedSelectors do: [:selectors | selectorsCandidates addAll: selectors ].
	
	selectorsCandidates 		sortedCounts
		do:[:assoc |
			(assoc key isEqualTo: subclasses size ) 			
				ifTrue: [selectorsToAdd add: assoc value ] 		].
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'X class' category: 'X'!
X class
	instanceVariableNames: ''!

!X class methodsFor: 'as yet unclassified' stamp: 'BLS 10/21/2022 17:16:41'!
for: aClassToRefactor
	
	^ (self new initializeWith: aClassToRefactor) m.
	! !


!classDefinition: #XMO category: 'X'!
Object subclass: #XMO
	instanceVariableNames: 'classToRefactor subclasses unsharedSelectors selectorsSubclasses selectorToCompile selectorsCandidates'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'X'!

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

!XMO methodsFor: 'compute -- private' stamp: 'FJH 10/24/2022 15:02:39'!
findSelectorsOfSubclasses
		
	subclasses do: [:subclass | selectorsSubclasses addAll: (XRecursion for: subclass) ] .
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


!XMO methodsFor: 'compute' stamp: 'FJH 10/24/2022 15:17:18'!
m
	
	self findSelectorsOfSubclasses .
	
	self selectSubclassSelectorsAreNotInClassSelectors.
	
	self selectCandidatesToCompile.
	
	self compileSelectors.
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

!classDefinition: 'XMO class' category: 'X'!
XMO class
	instanceVariableNames: ''!

!XMO class methodsFor: 'as yet unclassified' stamp: 'FJH 10/23/2022 15:55:56'!
for: aClassToRefactor
	
	^ (self new initializeWith: aClassToRefactor) m.
	! !


!classDefinition: #XRecursion category: 'X'!
Object subclass: #XRecursion
	instanceVariableNames: 'classToRecursion subclasses selectorsSubclasses unsharedSelectors'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'X'!

!XRecursion methodsFor: 'compute' stamp: 'FJH 10/24/2022 15:22:56'!
m
	
	self findSelectorsOfSubclasses.
		
	self selectSubclassSelectorsAreNotInClassSelectors.
	
	self addUnsharedSelectorToClassSelectors. 
	
	^ unsharedSelectors .! !


!XRecursion methodsFor: 'compute -- private' stamp: 'FJH 10/24/2022 15:22:48'!
addUnsharedSelectorToClassSelectors
	
	unsharedSelectors addAll: classToRecursion selectors.! !

!XRecursion methodsFor: 'compute -- private' stamp: 'FJH 10/24/2022 14:52:11'!
findSelectorsOfSubclasses
		
	subclasses do: [:subclass | selectorsSubclasses addAll: (XRecursion for: subclass) ] .
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

!classDefinition: 'XRecursion class' category: 'X'!
XRecursion class
	instanceVariableNames: ''!

!XRecursion class methodsFor: 'as yet unclassified' stamp: 'FJH 10/23/2022 15:07:38'!
for: aClassToRefactor
	
	^ (self new initializeWith: aClassToRefactor) m.
	! !


!classDefinition: #Y category: 'X'!
Object subclass: #Y
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'X'!


!classDefinition: #YY category: 'X'!
Y subclass: #YY
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'X'!

!YY methodsFor: 'as yet unclassified' stamp: 'FJH 10/24/2022 14:43:24'!
n! !
