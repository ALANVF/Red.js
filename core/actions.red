Red []

'FIGURE-THIS-OUT-LATER? [
make: make action! [[
		"Returns a new value made from a spec for that value's type"
		type	 [any-type!] "The datatype, an example or prototype value"
		spec	 [any-type!] "The specification of the new value"
		return:  [any-type!] "Returns the specified datatype"
	]
	make
]
]

'TODO [
random: make action! [[
		"Returns a random value of the same datatype; or shuffles series"
		value	"Maximum value of result (modified when series)"
		/seed   "Restart or randomize"
		/secure "TBD: Returns a cryptographically secure random number"
		/only	"Pick a random value from a series"
		return:	[any-type!]
	]
	random
]

reflect: make action! [[
		"Returns internal details about a value via reflection"
		value	[any-type!]
		field 	[word!] "spec, body, words, etc. Each datatype defines its own reflectors"
	]
	reflect
]
]

to: make action! [[
		"Converts to a specified datatype"
		type	[any-type!] "The datatype or example value"
		spec	[any-type!] "The attributes of the new value"
	]
	to
]

form: make action! [[
		"Returns a user-friendly string representation of a value"
		value	  [any-type!]
		/part "Limit the length of the result"
			limit [integer!]
		return:	  [string!]
	]
	form
]

mold: make action! [[
		"Returns a source format string representation of a value"
		value	  [any-type!]
		/only "Exclude outer brackets if value is a block"
		/all  "TBD: Return value in loadable format"
		/flat "TBD: Exclude all indentation"
		/part "Limit the length of the result"
			limit [integer!]
		return:	  [string!]
	]
	mold
]

'TODO [
modify: make action! [[
		"Change mode for target aggregate value"
		target	 [object! series!]
		field 	 [word!]
		value 	 [any-type!]
		/case "Perform a case-sensitive lookup"
	]
	modify
]
]

;-- Scalar actions --

absolute: make action! [[
		"Returns the non-negative value"
		value	 [number! char! pair! time!]
		return:  [number! char! pair! time!]
	]
	absolute
]

add: make action! [[
		"Returns the sum of the two values"
		value1	 [number! char! pair! tuple! vector! time! date!]
		value2	 [number! char! pair! tuple! vector! time! date!]
		return:  [number! char! pair! tuple! vector! time! date!]
	]
	add
]

divide: make action! [[
		"Returns the quotient of two values"
		value1	 [number! char! pair! tuple! vector! time!] "The dividend (numerator)"
		value2	 [number! char! pair! tuple! vector! time!] "The divisor (denominator)"
		return:  [number! char! pair! tuple! vector! time!]
	]
	divide
]

multiply: make action! [[
		"Returns the product of two values"
		value1	 [number! char! pair! tuple! vector! time!]
		value2	 [number! char! pair! tuple! vector! time!]
		return:  [number! char! pair! tuple! vector! time!]
	]
	multiply
]

negate: make action! [[
		"Returns the opposite (additive inverse) value"
		number 	 [number! bitset! pair! time!]
		return:  [number! bitset! pair! time!]
	]
	negate
]

power: make action! [[
		"Returns a number raised to a given power (exponent)"
		number	 [number!] "Base value"
		exponent [integer! float!] "The power (index) to raise the base value by"
		return:	 [number!]
	]
	power
]

remainder: make action! [[
		"Returns what is left over when one value is divided by another"
		value1 	 [number! char! pair! tuple! vector! time!]
		value2 	 [number! char! pair! tuple! vector! time!]
		return:  [number! char! pair! tuple! vector! time!]
	]
	remainder
]

'TODO [
round: make action! [[
		"Returns the nearest integer. Halves round up (away from zero) by default"
		n		[number! time! pair!]
		/to		"Return the nearest multiple of the scale parameter"
		scale	[number! time!] "Must be a non-zero value"
		/even		"Halves round toward even results"
		/down		"Round toward zero, ignoring discarded digits. (truncate)"
		/half-down	"Halves round toward zero"
		/floor		"Round in negative direction"
		/ceiling	"Round in positive direction"
		/half-ceiling "Halves round in positive direction"
	]
	round
]
]

subtract: make action! [[
		"Returns the difference between two values"
		value1	 [number! char! pair! tuple! vector! time! date!]
		value2	 [number! char! pair! tuple! vector! time! date!]
		return:  [number! char! pair! tuple! vector! time! date!]
	]
	subtract
]

'TODO [
even?: make action! [[
		"Returns true if the number is evenly divisible by 2"
		number 	 [number! char! time!]
		return:  [number! char! time!]
	]
	even_q
]

odd?: make action! [[
		"Returns true if the number has a remainder of 1 when divided by 2"
		number 	 [number! char! time!]
		return:  [number! char! time!]
	]
	odd_q
]
]

;-- Bitwise actions --

and~: make action! [[
		"Returns the first value ANDed with the second"
		value1	[logic! integer! char! bitset! binary! typeset! pair! tuple! vector!]
		value2	[logic! integer! char! bitset! binary! typeset! pair! tuple! vector!]
		return:	[logic! integer! char! bitset! binary! typeset! pair! tuple! vector!]
	]
	and_t
]

complement: make action! [[
		"Returns the opposite (complementing) value of the input value"
		value	[logic! integer! bitset! typeset! binary!]
		return: [logic! integer! bitset! typeset! binary!]
	]
	complement
]

or~: make action! [[
		"Returns the first value ORed with the second"
		value1	[logic! integer! char! bitset! binary! typeset! pair! tuple! vector!]
		value2	[logic! integer! char! bitset! binary! typeset! pair! tuple! vector!]
		return:	[logic! integer! char! bitset! binary! typeset! pair! tuple! vector!]
	]
	or_t
]

xor~: make action! [[
		"Returns the first value exclusive ORed with the second"
		value1	[logic! integer! char! bitset! binary! typeset! pair! tuple! vector!]
		value2	[logic! integer! char! bitset! binary! typeset! pair! tuple! vector!]
		return:	[logic! integer! char! bitset! binary! typeset! pair! tuple! vector!]
	]
	xor_t
]

;-- Series actions --

append: make action! [[
		"Inserts value(s) at series tail; returns series head"
		series	   [series! bitset! port!]
		value	   [any-type!]
		/part "Limit the number of values inserted"
			length [number! series!]
		/only "Insert block types as single values (overrides /part)"
		/dup  "Duplicate the inserted values"
			count  [integer!]
		return:    [series! port! bitset!]
	]
	append
]

at: make action! [[
		"Returns a series at a given index"
		series	 [series! port!]
		index 	 [integer! pair!]
		return:  [series! port!]
	]
	at
]

back: make action! [[
		"Returns a series at the previous index"
		series	 [series! port!]
		return:  [series! port!]
	]
	back
]

'TODO [
change: make action! [[
		"Changes a value in a series and returns the series after the change"
		series [series! port!] "Series at point to change"
		value [any-type!] "The new value"
		/part "Limits the amount to change to a given length or position"
			range [number! series!]
		/only "Changes a series as a series."
		/dup "Duplicates the change a specified number of times"
			count [number!]
	]
	change
]
]

clear: make action! [[
		"Removes series values from current index to tail; returns new tail"
		series	 [series! port! bitset! map! none!]
		return:  [series! port! bitset! map! none!]
	]
	clear
]

copy: make action! [[
		"Returns a copy of a non-scalar value"
		value	 [series! any-object! bitset! map!]
		/part	 "Limit the length of the result"
			length [number! series! pair!]
		/deep	 "Copy nested values"
		/types	 "Copy only specific types of non-scalar values"
			kind [datatype!]
		return:  [series! any-object! bitset! map!]
	]
	copy
]

'TODO [
find: make action! [[
		"Returns the series where a value is found, or NONE"
		series	 [series! bitset! typeset! port! map! none!]
		value 	 [any-type!]
		/part "Limit the length of the search"
			length [number! series!]
		/only "Treat a series search value as a single value"
		/case "Perform a case-sensitive search"
		/same {Use "same?" as comparator}
		/any  "TBD: Use * and ? wildcards in string searches"
		/with "TBD: Use custom wildcards in place of * and ?"
			wild [string!]
		/skip "Treat the series as fixed size records"
			size [integer!]
		/last "Find the last occurrence of value, from the tail"
		/reverse "Find the last occurrence of value, from the current index"
		/tail "Return the tail of the match found, rather than the head"
		/match "Match at current index only and return tail of match"
	]
	find
]
]

head: make action! [[
		"Returns a series at its first index"
		series	 [series! port!]
		return:  [series! port!]
	]
	head
]

head?: make action! [[
		"Returns true if a series is at its first index"
		series	 [series! port!]
		return:  [logic!]
	]
	head_q
]

index?: make action! [[
		"Returns the current index of series relative to the head, or of word in a context"
		series	 [series! port! any-word!]
		return:  [integer!]
	]
	index_q
]

'TODO [
insert: make action! [[
		"Inserts value(s) at series index; returns series past the insertion"
		series	   [series! port! bitset!]
		value	   [any-type!]
		/part "Limit the number of values inserted"
			length [number! series!]
		/only "Insert block types as single values (overrides /part)"
		/dup  "Duplicate the inserted values"
			count  [integer!]
		return:    [series! port! bitset!]
	]
	insert
]
]

length?: make action! [[
		"Returns the number of values in the series, from the current index to the tail"
		series	 [series! port! bitset! map! tuple! none!]
		return:  [integer! none!]
	]
	length_q
]

'TODO [
move: make action! [[
		"Moves one or more elements from one series to another position or series"
		origin	   [series! port!]
		target	   [series! port!]
		/part "Limit the number of values inserted"
			length [integer!]
		return:    [series! port!]
	]
	move
]
]

next: make action! [[
		"Returns a series at the next index"
		series	 [series! port!]
		return:  [series! port!]
	]
	next
]

pick: make action! [[
		"Returns the series value at a given index"
		series	 [series! port! bitset! pair! tuple! date! time!]
		index 	 [scalar! any-string! any-word! block! logic! time!]
		return:  [any-type!]
	]
	pick
]

poke: make action! [[
		"Replaces the series value at a given index, and returns the new value"
		series	 [series! port! bitset!]
		index 	 [scalar! any-string! any-word! block! logic!]
		value 	 [any-type!]
		return:  [series! port! bitset!]
	]
	poke
]

'TODO [
put: make action! [[
		"Replaces the value following a key, and returns the new value"
		series	 [series! port! map! object!]
		key 	 [scalar! any-string! any-word! binary!]
		value 	 [any-type!]
		/case "Perform a case-sensitive search"
		return:  [series! port! map! object!]
	]
	put
]

remove: make action! [[
		"Returns the series at the same index after removing a value"
		series	 [series! port! bitset! map! none!]
		/part "Removes a number of values, or values up to the given series index"
			length [number! char! series!]
		/key "Removes a key in map"
			key-arg [scalar! any-string! any-word! binary! block!]
		return:  [series! port! bitset! map! none!]
	]
	remove
]

reverse: make action! [[
		"Reverses the order of elements; returns at same position"
		series	 [series! port! pair! tuple!]
		/part "Limits to a given length or position"
			length [number! series!]
		return:  [series! port! pair! tuple!]
	]
	reverse
]

select: make action! [[
		"Find a value in a series and return the next value, or NONE"
		series	 [series! any-object! map! none!]
		value 	 [any-type!]
		/part "Limit the length of the search"
			length [number! series!]
		/only "Treat a series search value as a single value"
		/case "Perform a case-sensitive search"
		/same {Use "same?" as comparator}
		/any  "TBD: Use * and ? wildcards in string searches"
		/with "TBD: Use custom wildcards in place of * and ?"
			wild [string!]
		/skip "Treat the series as fixed size records"
			size [integer!]
		/last "Find the last occurrence of value, from the tail"
		/reverse "Find the last occurrence of value, from the current index"
		return:  [any-type!]
	]
	select
]

sort: make action! [[
		"Sorts a series (modified); default sort order is ascending"
		series	 [series! port!]
		/case "Perform a case-sensitive sort"
		/skip "Treat the series as fixed size records"
			size [integer!]
		/compare "Comparator offset, block (TBD) or function"
			comparator [integer! block! any-function!]
		/part "Sort only part of a series"
			length [number! series!]
		/all "Compare all fields"
		/reverse "Reverse sort order"
		/stable "Stable sorting"
		return:  [series!]
	]
	sort
]
]

skip: make action! [[
		"Returns the series relative to the current index"
		series	 [series! port!]
		offset 	 [integer! pair!]
		return:  [series! port!]
	]
	skip
]

'TODO [
swap: make action! [[
		"Swaps elements between two series or the same series"
		series1  [series! port!]
		series2  [series! port!]
		return:  [series! port!]
	]
	swap
]
]

tail: make action! [[
		"Returns a series at the index after its last value"
		series	 [series! port!]
		return:  [series! port!]
	]
	tail
]

tail?: make action! [[
		"Returns true if a series is past its last value"
		series	 [series! port!]
		return:  [logic!]
	]
	tail_q
]

'TODO [
take: make action! [[
		"Removes and returns one or more elements"
		series	 [series! port! none!]
		/part	 "Specifies a length or end position"
			length [number! series!]
		/deep	 "Copy nested values"
		/last	 "Take it from the tail end"
	]
	take
]

trim: make action! [[
		"Removes space from a string or NONE from a block"
		series	[series! port!]
		/head	"Removes only from the head"
		/tail	"Removes only from the tail"
		/auto	"Auto indents lines relative to first line"
		/lines	"Removes all line breaks and extra spaces"
		/all	"Removes all whitespace"
		/with	"Same as /all, but removes characters in 'str'"
			str [char! string! binary! integer!]
	]
	trim
]
]

;-- I/O actions --

'TODO [
create: make action! [[
		"Send port a create request"
		port [port! file! url! block!]
	]
	create
]

close: make action! [[
		"Closes a port"
		port [port!]
	]
	close
]

delete: make action! [[
		"Deletes the specified file or empty folder"
		file [file! port!]
	]
	delete
]

open: make action! [[
		"Opens a port; makes a new port from a specification if necessary"
		port [port! file! url! block!]
		/new "Create new file - if it exists, deletes it"
		/read "Open for read access"
		/write "Open for write access"
		/seek "Optimize for random access"
		/allow "Specificies right access attributes"
			access [block!]
	]
	open
]

open?: make action! [[
		"Returns TRUE if port is open"
		port [port!]
	]
	open_q
]

query: make action! [[
		"Returns information about a file"
		target [file! port!]
	]
	query
]

read: make action! [[
		"Reads from a file, URL, or other port"
		source	[file! url! port!]
		/part	"Partial read a given number of units (source relative)"
			length [number!]
		/seek	"Read from a specific position (source relative)"
			index [number!]
		/binary	"Preserves contents exactly"
		/lines	"Convert to block of strings"
		/info
		/as		"Read with the specified encoding, default is 'UTF-8"
			encoding [word!]
	]
	read
]

rename: make action! [[
		"Rename a file"
		from [port! file! url!]
		to   [port! file! url!]
	]
	rename
]

update: make action! [[
		"Updates external and internal states (normally after read/write)"
		port [port!]
	]
	update
]

write: make action! [[
		"Writes to a file, URL, or other port"
		destination	[file! url! port!]
		data		[any-type!]
		/binary	"Preserves contents exactly"
		/lines	"Write each value in a block as a separate line"
		/info
		/append "Write data at end of file"
		/part	"Partial write a given number of units"
			length	[number!]
		/seek	"Write at a specific position"
			index	[number!]
		/allow	"Specifies protection attributes"
			access	[block!]
		/as		"Write with the specified encoding, default is 'UTF-8"
			encoding [word!]
	]
	write
]
]