Very incomplete

Example usage:
```red
Red/JS []

#import [
	console: "console" object! [
		log: "log" function! [
			[variadic]
			args    [block!]
			return: [unset!]
		]
	]
]

console/log [1 2.3 "abc"] ;=> 1 2.3 'abc'

;-- Resulting JS code:
; console.log(1, 2.3, "abc");
```