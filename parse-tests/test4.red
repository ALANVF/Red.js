math: function [
	"Evaluates a block using math precedence rules, returning the last result"
	body [block!] "Block to evaluate"
	/safe		  "Returns NONE on error"
][
	parse body: copy/deep body rule: [
		any [
			pos: ['* (op: 'multiply) | quote / (op: 'divide)] 
			[ahead sub: paren! (sub/1: math as block! sub/1) | skip] (
				end: skip pos: back pos 3
				pos: change/only/part pos as paren! copy/part pos end end
			) :pos
			| into rule
			| skip
		]
	]
	either safe [attempt body][do body]
]