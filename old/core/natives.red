Red []

if: make native! [[
		"If conditional expression is TRUE, evaluate block; else return NONE"
		cond  	 [any-type!]
		then-blk [block!]
	]
	if
]

unless: make native! [[
		"If conditional expression is not TRUE, evaluate block; else return NONE"
		cond  	 [any-type!]
		then-blk [block!]
	]
	unless
]

either: make native! [[
		"If conditional expression is true, eval true-block; else eval false-blk"
		cond  	  [any-type!]
		true-blk  [block!]
		false-blk [block!]
	]
	either
]
	
any: make native! [[
		"Evaluates, returning at the first that is true"
		conds [block!]
	]
	any
]

all: make native! [[
		"Evaluates, returning at the first that is not true"
		conds [block!]
	]
	all
]

while: make native! [[
		"Evaluates body as long as condition block returns TRUE"
		cond [block!]	"Condition block to evaluate on each iteration"
		body [block!]	"Block to evaluate on each iteration"
	]
	while
]
	
until: make native! [[
		"Evaluates body until it is TRUE"
		body [block!]
	]
	until
]

loop: make native! [[
		"Evaluates body a number of times"
		count [integer!]
		body  [block!]
	]
	loop
]

repeat: make native! [[
		"Evaluates body a number of times, tracking iteration count"
		'word [word!]    "Iteration counter; not local to loop"
		value [integer!] "Number of times to evaluate body"
		body  [block!]
	]
	repeat
]

forever: make native! [[
		"Evaluates body repeatedly forever"
		body   [block!]
	]
	forever
]

foreach: make native! [[
		"Evaluates body for each value in a series"
		'word  [word! block!]   "Word, or words, to set on each iteration"
		series [series! map!]
		body   [block!]
	]
	foreach
]

'TODO [
forall: make native! [[
		"Evaluates body for all values in a series"
		'word [word!]   "Word referring to series to iterate over"
		body  [block!]
	]
	forall
]

remove-each: make native! [[
		"Removes values for each block that returns true"
		'word [word! block!] "Word or block of words to set each time"
		data [series!] "The series to traverse (modified)"
		body [block!] "Block to evaluate (return TRUE to remove)"
	]
	remove_each
]
]

func: make native! [[
		"Defines a function with a given spec and body"
		spec [block!]
		body [block!]
	]
	func
]

'TODO [
function: make native! [[
		"Defines a function, making all set-words found in body, local"
		spec [block!]
		body [block!]
		/extern	"Exclude words that follow this refinement"
	]
	function
]
]

does: make native! [[
		"Defines a function with no arguments or local variables"
		body [block!]
	]
	does
]

has: make native! [[
		"Defines a function with local variables, but no arguments"
		vars [block!]
		body [block!]
	]
	has
]

switch: make native! [[
		"Evaluates the first block following the value found in cases"
		value [any-type!] "The value to match"
		cases [block!]
		/default "Specify a default block, if value is not found in cases"
			case [block!] "Default block to evaluate"
	]
	switch
]

case: make native! [[
		"Evaluates the block following the first true condition"
		cases [block!] "Block of condition-block pairs"
		/all "Test all conditions, evaluating the block following each true condition"
	]
	case
]

do: make native! [[
		"Evaluates a value, returning the last evaluation result"
		value [any-type!]
		/expand "Expand directives before evaluation"
		/args "If value is a script, this will set its system/script/args"
			arg "Args passed to a script (normally a string)"
		/next "Do next expression only, return it, update block word"
			position [word!] "Word updated with new block position"
	]
	do
]

reduce: make native! [[
		"Returns a copy of a block, evaluating all expressions"
		value [any-type!]
		/into "Put results in out block, instead of creating a new block"
			out [any-block!] "Target block for results, when /into is used"
	]
	reduce
]

compose: make native! [[
		"Returns a copy of a block, evaluating only parens"
		value [block!]
		/deep "Compose nested blocks"
		/only "Compose nested blocks as blocks containing their values"
		/into "Put results in out block, instead of creating a new block"
			out [any-block!] "Target block for results, when /into is used"
	]
	compose
]

get: make native! [[
		"Returns the value a word refers to"
		word	[any-word! refinement! path! object!]
		/any  "If word has no value, return UNSET rather than causing an error"
		/case "Use case-sensitive comparison (path only)"
		return: [any-type!]
	] 
	get
]

'FIGURE-THIS-OUT-LATER? [
set: make native! [[
		"Sets the value(s) one or more words refer to"
		word	[any-word! block! object! path!] "Word, object, map path or block of words to set"
		value	[any-type!] "Value or block of values to assign to words"
		/any  "Allow UNSET as a value rather than causing an error"
		/case "Use case-sensitive comparison (path only)"
		/only "Block or object value argument is set as a single value"
		/some "None values in a block or object value argument, are not set"
		return: [any-type!]
	]
	set
]
]

print: make native! [[
		"Outputs a value followed by a newline"
		value	[any-type!]
		/debug "Red.js-specific option. Internal use only"
	]
	print
]

prin: make native! [[
		"Outputs a value"
		value	[any-type!]
	]
	prin
]

equal?: make native! [[
		"Returns TRUE if two values are equal"
		value1 [any-type!]
		value2 [any-type!]
	]
	equal_q
]

not-equal?: make native! [[
		"Returns TRUE if two values are not equal"
		value1 [any-type!]
		value2 [any-type!]
	]
	not_equal_q
]

strict-equal?: make native! [[
		"Returns TRUE if two values are equal, and also the same datatype"
		value1 [any-type!]
		value2 [any-type!]
	]
	strict_equal_q
]

lesser?: make native! [[
		"Returns TRUE if the first value is less than the second"
		value1 [any-type!]
		value2 [any-type!]
	]
	lesser_q
]

greater?: make native! [[
		"Returns TRUE if the first value is greater than the second"
		value1 [any-type!]
		value2 [any-type!]
	]
	greater_q
]

lesser-or-equal?: make native! [[
		"Returns TRUE if the first value is less than or equal to the second"
		value1 [any-type!]
		value2 [any-type!]
	]
	lesser_or_equal_q
]

greater-or-equal?: make native! [[
		"Returns TRUE if the first value is greater than or equal to the second"
		value1 [any-type!]
		value2 [any-type!]
	]
	greater_or_equal_q
]

same?: make native! [[
		"Returns TRUE if two values have the same identity"
		value1 [any-type!]
		value2 [any-type!]
	]
	same_q
]

not: make native! [[
		"Returns the boolean complement of a value"
		value [any-type!]
	]
	not
]

type?: make native! [[
		"Returns the datatype of a value"
		value [any-type!]
		/word "Return a word value, rather than a datatype value"
	]
	type_q
]

'TODO [
stats: make native! [[
		"Returns interpreter statistics"
		/show "TBD:"
		/info "Output formatted results"
		return: [integer! block!]
	]
	stats
]

bind: make native! [[
		"Bind words to a context; returns rebound words"
		word 	[block! any-word!]
		context [any-word! any-object! function!]
		/copy	"Deep copy blocks before binding"
		return: [block! any-word!]
	]
	bind
]

in: make native! [[
		"Returns the given word bound to the object's context"
		object [any-object!]
		word   [any-word!]
	]
	in
]

parse: make native! [[
		"Process a series using dialected grammar rules"
		input [binary! any-block! any-string!]
		rules [block!]
		/case "Uses case-sensitive comparison"
		;/strict
		/part "Limit to a length or position"
			length [number! series!]
		/trace
			callback [function! [
				event	[word!]
				match?	[logic!]
				rule	[block!]
				input	[series!]
				stack	[block!]
				return: [logic!]
			]]
		return: [logic! block!]
	]
	parse
]
]

union: make native! [[
		"Returns the union of two data sets"
		set1 [block! hash! string! bitset! typeset!]
		set2 [block! hash! string! bitset! typeset!]
		/case "Use case-sensitive comparison"
		/skip "Treat the series as fixed size records"
			size [integer!]
		return: [block! hash! string! bitset! typeset!]
	]
	union
]

'TODO [
unique: make native! [[
		"Returns the data set with duplicates removed"
		set [block! hash! string!]
		/case "Use case-sensitive comparison"
		/skip "Treat the series as fixed size records"
			size [integer!]
		return: [block! hash! string!]
	]
	unique
]

intersect: make native! [[
		"Returns the intersection of two data sets"
		set1 [block! hash! string! bitset! typeset!]
		set2 [block! hash! string! bitset! typeset!]
		/case "Use case-sensitive comparison"
		/skip "Treat the series as fixed size records"
			size [integer!]
		return: [block! hash! string! bitset! typeset!]
	]
	intersect
]

difference: make native! [[
		"Returns the special difference of two data sets"
		set1 [block! hash! string! bitset! typeset! date!]
		set2 [block! hash! string! bitset! typeset! date!]
		/case "Use case-sensitive comparison"
		/skip "Treat the series as fixed size records"
			size [integer!]
		return: [block! hash! string! bitset! typeset! time!]
	]
	difference
]

exclude: make native! [[
		"Returns the first data set less the second data set"
		set1 [block! hash! string! bitset! typeset!]
		set2 [block! hash! string! bitset! typeset!]
		/case "Use case-sensitive comparison"
		/skip "Treat the series as fixed size records"
			size [integer!]
		return: [block! hash! string! bitset! typeset!]
	]
	exclude
]

complement?: make native! [[
		"Returns TRUE if the bitset is complemented"
		bits [bitset!]
	]
	complement_q
]

dehex: make native! [[
		"Converts URL-style hex encoded (%xx) strings"
		value [any-string!]
		return:	[string!] "Always return a string"
	]
	dehex
]
]


negative?: make native! [[
		"Returns TRUE if the number is negative"
		number [number! time!]
	]
	negative_q
]

positive?: make native! [[
		"Returns TRUE if the number is positive"
		number [number! time!]
	]
	positive_q
]

max: make native! [[
		"Returns the greater of the two values"
		value1 [scalar! series!]
		value2 [scalar! series!]
	]
	max
]

min: make native! [[
		"Returns the lesser of the two values"
		value1 [scalar! series!]
		value2 [scalar! series!]
	]
	min
]

shift: make native! [[
		"Perform a bit shift operation. Right shift (decreasing) by default"
		data	[integer!]
		bits	[integer!]
		/left	 "Shift bits to the left (increasing)"
		/logical "Use logical shift (unsigned, fill with zero)"
		return: [integer!]
	]
	shift
]

'TODO [
to-hex: make native! [[
		"Converts numeric value to a hex issue! datatype (with leading # and 0's)"
		value	[integer!]
		/size "Specify number of hex digits in result"
			length [integer!]
		return: [issue!]
	]
	to_hex
]
]

sine: make native! [[
		"Returns the trigonometric sine"
		angle	[number!]
		/radians "Angle is specified in radians"
		return: [float!]
	]
	sine
]

cosine: make native! [[
		"Returns the trigonometric cosine"
		angle	[number!]
		/radians "Angle is specified in radians"
		return: [float!]
	]
	cosine
]

tangent: make native! [[
		"Returns the trigonometric tangent"
		angle	[number!]
		/radians "Angle is specified in radians"
		return: [float!]
	]
	tangent
]

arcsine: make native! [[
		"Returns the trigonometric arcsine (in degrees by default in range [-90,90])"
		sine	[number!] "in range [-1,1]"
		/radians "Angle is returned in radians [-pi/2,pi/2]"
		return: [float!]
	]
	arcsine
]

arccosine: make native! [[
		"Returns the trigonometric arccosine (in degrees by default in range [0,180])"
		cosine	[number!] "in range [-1,1]"
		/radians "Angle is returned in radians [0,pi]"
		return: [float!]
	]
	arccosine
]

arctangent: make native! [[
		"Returns the trigonometric arctangent (in degrees by default in range [-90,90])"
		tangent	[number!] "in range [-inf,+inf]"
		/radians "Angle is returned in radians [-pi/2,pi/2]"
		return: [float!]
	]
	arctangent
]

arctangent2: make native! [[
		"Returns the smallest angle between the vectors (1,0) and (x,y) in degrees by default (-180,180]"
		y       [number!]
		x       [number!]
		/radians "Angle is returned in radians (-pi,pi]"
		return: [float!]
	]
	arctangent2
]

nan?: make native! [[
		"Returns TRUE if the number is Not-a-Number"
		value	[number!]
		return: [logic!]
	]
	nan_q
]

zero?: make native! [[
		"Returns TRUE if the value is zero"
		value	[number! pair! time! char! tuple!]
		return: [logic!]
	]
	zero_q
]

log-2: make native! [[
		"Return the base-2 logarithm"
		value	[number!]
		return: [float!]
	]
	log_2
]

log-10: make native! [[
		"Returns the base-10 logarithm"
		value	[number!]
		return: [float!]
	]
	log_10
]

log-e: make native! [[
		"Returns the natural (base-E) logarithm of the given value"
		value	[number!]
		return: [float!]
	]
	log_e
]

exp: make native! [[
		"Raises E (the base of natural logarithm) to the power specified"
		value	[number!]
		return: [float!]
	]
	exp
]

square-root: make native! [[
		"Returns the square root of a number"
		value	[number!]
		return: [float!]
	]
	square_root
]

'TODO [
construct: make native! [[
		"Makes a new object from an unevaluated spec; standard logic words are evaluated"
		block [block!]
		/with "Use a prototype object"
			object [object!] "Prototype object"
		/only "Don't evaluate standard logic words"
	]
	construct
]
]

value?: make native! [[
		"Returns TRUE if the word has a value"
		value
		return: [logic!]
	]
	value_q
]

'TODO [
try: make native! [[
		"Tries to DO a block and returns its value or an error"
		block	[block!]
		/all "Catch also BREAK, CONTINUE, RETURN, EXIT and THROW exceptions"
	]
	try
]

uppercase: make native! [[
		"Converts string of characters to uppercase"
		string		[any-string! char!]
		/part "Limits to a given length or position"
			limit	[number! any-string!]
		return: 	[any-string! char!]
	]
	uppercase
]

lowercase: make native! [[
		"Converts string of characters to lowercase"
		string		[any-string! char!]
		/part "Limits to a given length or position"
			limit	[number! any-string!]
		return:		[any-string! char!]
	]
	lowercase
]

as-pair: make native! [[
		"Combine X and Y values into a pair"
		x [integer! float!]
		y [integer! float!]
	]
	as_pair
]
]

break: make native! [[
		"Breaks out of a loop, while, until, repeat, foreach, etc"
		/return "Forces the loop function to return a value"
			value [any-type!]
	]
	break
]

continue: make native! [[
		"Throws control back to top of loop"
	]
	continue
]

exit: make native! [[
		"Exits a function, returning no value"
	]
	exit
]

return: make native! [[
		"Returns a value from a function"
		value [any-type!]
	]
	return
]

'TODO [
throw: make native! [[
		"Throws control back to a previous catch"
		value [any-type!] "Value returned from catch"
		/name "Throws to a named catch"
			word [word!]
	]
	throw
]

catch: make native! [[
		"Catches a throw from a block and returns its value"
		block [block!] "Block to evaluate"
		/name "Catches a named throw"
			word [word! block!] "One or more names"
	]
	catch
]

extend: make native! [[
		"Extend an object or map value with list of key and value pairs"
		obj  [object! map!]
		spec [block! hash! map!]
		/case "Use case-sensitive comparison"
	]
	extend
]

debase: make native! [[
		"Decodes binary-coded string (BASE-64 default) to binary value"
		value [string!] "The string to decode"
		/base "Binary base to use"
			base-value [integer!] "The base to convert from: 64, 58, 16, or 2"
	]
	debase
]

enbase: make native! [[
		"Encodes a string into a binary-coded string (BASE-64 default)"
		value [binary! string!] "If string, will be UTF8 encoded"
		/base "Binary base to use"
			base-value [integer!] "The base to convert from: 64, 58, 16, or 2"
	]
	enbase
]

to-local-file: make native! [[
		"Converts a Red file path to the local system file path"
		path  [file! string!]
		/full "Prepends current dir for full path (for relative paths only)"
		return: [string!]
	]
	to_local_file
]

wait: make native! [[
		"Waits for a duration in seconds or specified time"
		value [number! time! block! none!]
		/all "Returns all events in a block"
		;/only "Only check for ports given in the block to this function"
	]
	wait
]

checksum: make native! [[
		"Computes a checksum, CRC, hash, or HMAC"
		data 	[binary! string! file!]
		method	[word!]	"MD5 SHA1 SHA256 SHA384 SHA512 CRC32 TCP ADLER32 hash"
		/with	"Extra value for HMAC key or hash table size; not compatible with TCP/CRC32/ADLER32 methods"
			spec [any-string! binary! integer!] "String or binary for MD5/SHA* HMAC key, integer for hash table size"
		return: [integer! binary!]
	]
	checksum
]
]

unset: make native! [[
		"Unsets the value of a word in its current context"
		word [word! block!]  "Word or block of words"
	]
	unset
]

'TODO [
new-line: make native! [[
		"Sets or clears the new-line marker within a list series"
		position [any-list!] "Position to change marker (modified)"
		value	 [logic!]	 "Set TRUE for newline"
		/all				 "Set/clear marker to end of series"
		/skip				 "Set/clear marker periodically to the end of the series"
			size [integer!]
		return:  [any-list!]
	]
	new_line
]

new-line?: make native! [[
		"Returns the state of the new-line marker within a list series"
		position [any-list!] "Position to change marker"
		return:  [any-list!]
	]
	new_line_q
]

context?: make native! [[
		"Returns the context in which a word is bound"
		word	[any-word!]		"Word to check"
		return: [object! function! none!]
	]
	context_q
]

set-env: make native! [[
		"Sets the value of an operating system environment variable (for current process)"
		var   [any-string! any-word!] "Variable to set"
		value [string! none!] "Value to set, or NONE to unset it"
	]
	set_env
]

get-env: make native! [[
		"Returns the value of an OS environment variable (for current process)"
		var		[any-string! any-word!] "Variable to get"
		return: [string! none!]
	]
	get_env
]

list-env: make native! [[
		"Returns a map of OS environment variables (for current process)"
		return: [map!]
	]
	list_env
]

now: make native! [[
		"Returns date and time"
		/year		"Returns year only"
		/month		"Returns month only"
		/day		"Returns day of the month only"
		/time		"Returns time only"
		/zone		"Returns time zone offset from UTC (GMT) only"
		/date		"Returns date only"
		/weekday	"Returns day of the week as integer (Monday is day 1)"
		/yearday	"Returns day of the year (Julian)"
		/precise	"High precision time"
		/utc		"Universal time (no zone)"
		return: [date! time! integer!]
	]
	now
]

sign?: make native! [[
		"Returns sign of N as 1, 0, or -1 (to use as a multiplier)"
		number [number! time!]
	]
	sign_q
]

as: make native! [[
		"Coerce a series into a compatible datatype without copying it"
		type	[datatype! block! paren! any-path! any-string!] "The datatype or example value"
		spec	[block! paren! any-path! any-string!] "The series to coerce"
	]
	as
]

call: make native! [[
		"Executes a shell command to run another process"
		cmd			[string! file!]			"A shell command or an executable file"
		/wait								"Runs command and waits for exit"
		/show								"Force the display of system's shell window (Windows only)"
		/console							"Runs command with I/O redirected to console (CLI console only at present)"
		/shell								"Forces command to be run from shell"
		/input	in	[string! file! binary!]	"Redirects in to stdin"
		/output	out	[string! file! binary!]	"Redirects stdout to out"
		/error	err	[string! file! binary!]	"Redirects stderr to err"
		return:		[integer!]				"0 if success, -1 if error, or a process ID"
	]
	call
]

size?: make native! [[
		"Returns the size of a file content"
		file 	[file!]
		return: [integer! none!]
	]
	size_q
]

browse: make native! [[
		"Open web browser to a URL or file mananger to a local file"
		url		[url! file!]
	]
	browse
]

compress: make native! [[
		"compresses data. return GZIP format (RFC 1952) by default"
		data		[any-string! binary!]
		/zlib		"Return ZLIB format (RFC 1950)"
		/deflate	"Return DEFLATE format (RFC 1951)"
	]
	compress
]

decompress: make native! [[
		"Decompresses data. Data in GZIP format (RFC 1952) by default"
		data		[binary!]
		/zlib		"Data in ZLIB format (RFC 1950)"
		size		[integer!] "Uncompressed data size. Use 0 if don't know"
		/deflate	"Data in DEFLATE format (RFC 1951)"
		size		[integer!] "Uncompressed data size. Use 0 if don't know"
	]
	decompress
]

recycle: make native! [[
		"Recycles unused memory"
		/on		"Turns on garbage collector"
		/off	"Turns off garbage collector"
	]
	recycle
]

transcode: make native! [[
		"Translates UTF-8 binary source to values. Returns one or several values in a block"
		src	 [binary! string!]	"UTF-8 input buffer; string argument will be UTF-8 encoded"
		/next			"Translate next complete value (blocks as single value)"
		/one			"Translate next complete value, returns the value only"
		/prescan		"Prescans only, do not load values. Returns guessed type."
		/scan			"Scans only, do not load values. Returns recognized type."
		/part			"Translates only part of the input buffer"
			length [integer! binary!] "Length in bytes or tail position"
		/into			"Optionally provides an output block"
			dst	[block! none!]
		/trace
			callback [function! [
				event	[word!]
				input	[binary! string!]
				type	[word! datatype!]
				line	[integer!]
				token
				return: [logic!]
			]]
		return: [block!]
	]
	transcode
]
]