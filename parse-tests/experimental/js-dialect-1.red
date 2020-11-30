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

fact: func [
	n       [number!]
	return: [number!]
][
	return either n = 0 [
		1
	][
		n * fact n - 1
	]
]

console/log fact 5



;-- Output:
comment {
	function fact(n) {
		(typeof n === 'number') || throw new TypeError("Parameter `n` was expected to be a number!");

		if(n == 0) {
			return 1;
		} else {
			return n * fact(n - 1);
		}
	}

	console.log(fact(5));
}