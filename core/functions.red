Red [
	Title:   "Red base environment definitions"
	File: 	 %functions.red
]

join: func [
	"Concatenates values."
	value "Base value"
	rest  "Value or block of values"
][
	value: either series? :value [copy value][form :value] 
	append value reduce :rest
]

also: func [
	"Returns the first value, but also evaluates the second"
	value1 [any-type!]
	value2 [any-type!]
][
	get/any 'value1
]

comment: func ["Consume but don't evaluate the next value" 'value][]

empty?: func [
	"Returns true if a series is at its tail or a map! is empty"
	series	[series! none! map!]
	return:	[logic!]
][
	case [
		series? series [tail? series]
		;map? series [series = #()]   ;@@ need to add support for map! literals first
		none? series [true]
	]
]

??: func [
	"Prints a word and the value it refers to (molded)"
	'value [word! path!]
][
	prin mold :value
	prin ": "
	print either value? :value [mold get/any :value]["unset!"]
]

probe: func [
	"Returns a value after printing its molded form"
	value [any-type!]
][
	print mold :value 
	:value
]

quote: func [
	"Return but don't evaluate the next value"
	:value
][
	:value
]

first:	func ["Returns the first value in a series"  s [series! tuple! pair! date! time!]] [pick s 1]	;@@ temporary definitions, should be natives ?
second:	func ["Returns the second value in a series" s [series! tuple! pair! date! time!]] [pick s 2]
third:	func ["Returns the third value in a series"  s [series! tuple! date! time!]] [pick s 3]
fourth:	func ["Returns the fourth value in a series" s [series! tuple! date!]] [pick s 4]
fifth:	func ["Returns the fifth value in a series"  s [series! tuple! date!]] [pick s 5]

last: func ["Returns the last value in a series" s [series! tuple!]] [pick s length? s]

;-- temporary for now
make-type-funcs: has [list to-list test-list _name docstring][
	list: copy []
	to-list: [
		bitset! binary! block! char! email! file! float! get-path! get-word! hash!
		integer! issue! lit-path! lit-word! logic! map! none! pair! paren! path!
		percent! refinement! set-path! set-word! string! tag! time! typeset! tuple!
		unset! url! word! date!
	]
	test-list: append copy to-list [
		action! native! datatype! function! object! op! vector!
	]
	
	;-- Generates all type testing functions (action?, bitset?, binary?,...)

	foreach name test-list [
		_name: form name
		poke back tail _name 1 #"?"

		append list reduce [
			to set-word! _name to word! 'func
			copy ["Returns true if the value is this type" value [any-type!]] ;@@ FIX: this breaks without copy
			compose [(name) = type? :value]
		]
	]
	
	;-- Generates all typesets testing functions (any-list?, any-block?,...)
	
	docstring: "Returns true if the value is any type of "
	foreach name [
		any-list! any-block! any-function! any-object! any-path! any-string! any-word!
		series! number! immediate! scalar! all-word!
	][
		_name: form name
		poke back tail _name 1 #"?"
		
		append list reduce [
			to set-word! _name to word! 'func
			compose [(poke back tail _name 1 #"."  append copy docstring _name) value [any-type!]]
			;compose [find (name) type? :value]
			compose [foreach type to block! (name) [if type = type? :value [return true]] false]
		]
	]
	
	;-- Generates all conversion wrapper functions (to-bitset, to-binary, to-block,...)

	;foreach name to-list [
	;	repend list [
	;		to set-word! join "to-" head remove back tail form name 'func
	;		reduce [reform ["Convert to" name "value"] 'value]
	;		compose [to (name) :value]
	;	]
	;]
	
	do list
]
make-type-funcs
unset 'make-type-funcs

context: func [
	"Makes a new object from an evaluated spec"
	spec [block!]
][
	make object! spec
]

offset?: func [
	"Returns the offset between two series positions"
	series1 [series!]
	series2 [series!]
][
	subtract index? series2 index? series1
]

charset: func [
	"Shortcut for `make bitset!`"
	spec [block! integer! char! string! bitset! binary!]
][
	make bitset! spec
]

rejoin: func [
	"Reduces and joins a block of values."
	block [block!] "Values to reduce and join"
][
	if empty? block: reduce block [return block] 
	append either series? first block [copy first block][
		form first block
	] next block
]

sum: func [
	"Returns the sum of all values in a block"
	values [block! vector! paren! hash!]
	/local result value
][
	result: make any [values/1 0] 0
	foreach value values [result: result + value]
	result
]

last?: func [
	"Returns TRUE if the series length is 1"
	series [series!]
] [
	1 = length? series
]

single?:	:last?
object:		:context