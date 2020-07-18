Red [
	Title:   "Red base environment definitions"
	File: 	 %functions.red
]

;join: func [
;	"Concatenates values."
;	value "Base value"
;	rest  "Value or block of values"
;][
;	value: either series? :value [copy value][form :value] 
;	append value reduce :rest
;]

shift-left: func [
	"Shift bits to the left"
	data [integer!]
	bits [integer!]
][
	shift/left data bits
]

shift-right: func [
	"Shift bits to the right"
	data [integer!]
	bits [integer!]
][
	shift data bits
]

shift-logical: func [
	"Shift bits to the right (unsigned)"
	data [integer!]
	bits [integer!]
][
	shift/logical data bits
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
		map? series [series = #()]
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
make-type-funcs: has [list to-list test-list docstring][
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
	
	;-- Generates all accessor functions (spec-of, body-of, words-of,...)
	
	foreach [name desc][
		spec   "Returns the spec of a value that supports reflection"
		body   "Returns the body of a value that supports reflection"
		words  "Returns the list of words of a value that supports reflection"
		class  "Returns the class ID of an object"
		values "Returns the list of values of a value that supports reflection"
	][
		append list reduce [
			to set-word! append form name "-of" 'func reduce [desc 'value] compose [
				reflect :value (to lit-word! name)
			] off
		]
	]
	
	;-- Generates all type testing functions (action?, bitset?, binary?,...)

	foreach name test-list [
		append list reduce [
			to set-word! head change back tail form name "?" 'func
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
		append list reduce [
			to set-word! head change back tail form name "?" 'func
			compose [(append copy docstring head clear back tail form name) value [any-type!]]
			;compose [find (name) type? :value]
			compose [foreach type to block! (name) [if type = type? :value [return true]] false]
		]
	]
	
	;-- Generates all conversion wrapper functions (to-bitset, to-binary, to-block,...)

	foreach name to-list [
		append list reduce [
			to set-word! append copy "to-" head remove back tail form name 'func
			reduce [form reduce ["Convert to" name "value"] 'value]
			compose [to (name) :value]
		]
	]
	
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

repend: func [
	"Appends a reduced value to a series and returns the series head"
	series [series!]
	value
	/only "Appends a block value as a block"
][
	head either any [only not any-block? series][
		insert/only tail series reduce :value
	][
		reduce/into :value tail series					;-- avoids wasting an intermediary block
	]
]

charset: func [
	"Shortcut for `make bitset!`"
	spec [block! integer! char! string! bitset! binary!]
][
	make bitset! spec
]

pad: func [
	"Pad a FORMed value on right side with spaces"
	str					"Value to pad, FORM it if not a string"
	n		[integer!]	"Total size (in characters) of the new string"
	/left				"Pad the string on left side"
	/with				"Pad with char"
	c		[char!]
	return:	[string!]	"Modified input string at head"
][
	unless string? str [str: form str]
	head insert/dup
		any [all [left str] tail str]
		any [c #" "]
		(n - length? str)
]

mod: func [
	"Compute a nonnegative remainder of A divided by B"
	a		[number! money! char! pair! tuple! vector! time!]
	b		[number! money! char! pair! tuple! vector! time!]	"Must be nonzero"
	return: [number! money! char! pair! tuple! vector! time!]
	/local r
][
	if (r: a % b) < 0 [r: r + b]
	a: absolute a
	either all [a + r = (a + b) r + r - b > 0][r - b][r]
]

modulo: func [
	"Wrapper for MOD that handles errors like REMAINDER. Negligible values (compared to A and B) are rounded to zero"
	a		[number! money! char! pair! tuple! vector! time!]
	b		[number! money! char! pair! tuple! vector! time!]
	return: [number! money! char! pair! tuple! vector! time!]
	/local r
][
	r: mod a absolute b
	either any [a - r = a r + b = b][0][r]
]

extract: func [
	"Extracts a value from a series at regular intervals"
	series	[series!]
	width	[integer!]	 "Size of each entry (the skip)"
	/index				 "Extract from an offset position"
		pos [integer!]	 "The position" 
	/into				 "Provide an output series instead of creating a new one"
		output [series!] "Output series"
][
	width: max 1 width
	if pos [series: at series pos]
	unless into [output: make series (length? series) / width]
	
	while [not tail? series][
		append/only output series/1
		series: skip series width
	]
	output
]

cos: func [
	"Returns the trigonometric cosine"
	angle [float!] "Angle in radians"
][
	cosine/radians angle
]

sin: func [
	"Returns the trigonometric sine"
	angle [float!] "Angle in radians"
][
	sine/radians angle
]

tan: func [
	"Returns the trigonometric tangent"
	angle [float!] "Angle in radians"
][
	tan/radians angle
]

acos: func [
	"Returns the trigonometric arccosine (in radians in range [0,pi])"
	cosine [float!] "in range [-1,1]"
][
	arccosine/radians cosine
]

asin: func [
	"Returns the trigonometric arcsine (in radians in range [-pi/2,pi/2])"
	sine [float!] "in range [-1,1]"
][
	arcsine/radians sine
]

atan: func [
	"Returns the trigonometric arctangent (in radians in range [-pi/2,+pi/2])"
	tangent [float!] "in range [-inf,+inf]"
][
	arctangent/radians tangent
]

atan2: func [
	"Returns the smallest angle between the vectors (1,0) and (x,y) in range (-pi,pi]"
	y		[number!]
	x		[number!]
	return:	[float!]
][
	arctangent2/radians y x
]


sqrt: func [
	"Returns the square root of a number"
	number	[number!]
	return:	[float!]
][
	square-root number
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

average: func [
	"Returns the average of all values in a block"
	block [block! vector! paren! hash!]
][
	if empty? block [return none]
	divide sum block to float! length? block
]

last?: func [
	"Returns TRUE if the series length is 1"
	series [series!]
][
	1 = length? series
]

single?:	:last?
object:		:context