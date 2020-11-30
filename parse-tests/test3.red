Red [
	Title: "Interactive functions"
	File:  %interactive.red
]

;-- This won't be implemented the way it is in normal Red for now.
;-- Actual implementation: https://github.com/red/red/blob/master/environment/console/help.red

help-ctx: context [
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

	set 'a-an func [
		"Returns the appropriate variant of a or an (simple, vs 100% grammatically correct)"
		str [string!]
		/pre "Prepend to str"
		/local tmp
	][
		tmp: either find "aeiou" str/1 ["an"] ["a"]
		either pre [rejoin [tmp #" " str]][tmp]
	]

	set 'help func [
		"Displays information about functions, values, objects, and datatypes."
		'word [any-type!]
		/local
			val val-type
	][
		
		case [
			unset? :word [
				;print HELP-USAGE
				print help-ctx/HELP-USAGE
			]

			any [
				word? :word  get-word? :word
				path? :word  get-path? :word
			] [
				either unset! = val-type: type? val: get/any :word [
					print reduce ["No information on" :word]
				][
					print reduce [:word "is" a-an/pre form val-type "of value:" mold :val]
				]
			]

			'else [
				print reduce [mold :word "is" a-an/pre form type? :word]
			]
		]
	]

	set '? :help
]