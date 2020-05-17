Red [
	Title: "Interactive functions"
	File:  %interactive.red
]

;-- This won't be implemented the way it is in normal Red for now.
;-- Actual implementation: https://github.com/red/red/blob/master/environment/console/help.red

help: none
?: none
help-ctx: make context! [
	HELP-USAGE:
{Use HELP or ? to view built-in docs for functions, values 
for contexts, or all values of a given datatype:
	help append
	? system
	? function!
To search for values by name, use a word:
	? pri
	? to-
To also search in function specs, use a string:
	? "pri"
	? "issue!"
Other useful functions:
	??     - Display a word and the value it references
	probe  - Print a molded value
	source - Show a function's source code
	what   - Show a list of known functions or words
	about  - Display version number and build date
	quit   - Leave the Red console}

	set 'help func [
		"Displays information about functions, values, objects, and datatypes."
		'word [any-type!]
		/local
			val val-type
	][
		case [
			unset! = type? :word [
				print HELP-USAGE
			]

			any [
				word! = type? :word  get-word! = type? :word
				path! = type? :word  get-path! = type? :word
			] [
				either unset! = val-type: type? val: get/any :word [
					print form reduce ["No information on" :word]
				][
					print form reduce [:word "is a(n)" val-type "of value:" mold :val]
				]
			]

			'else [
				print form reduce [mold :word "is a(n)" type? :word]
			]
		]
	]

	set '? :help
]