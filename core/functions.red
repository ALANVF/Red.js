Red [
	Title:   "Red base environment definitions"
	File: 	 %functions.red
]

also: func [
	"Returns the first value, but also evaluates the second"
	value1 [any-type!]
	value2 [any-type!]
][
	get/any 'value1
]

comment: func ["Consume but don't evaluate the next value" 'value][]

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