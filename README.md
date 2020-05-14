﻿# Red.js

Red.js is a web runtime for the [Red programming language](https://www.red-lang.org/) that allows you use Red right in your browser. Although it's currently very incomplete, the end goal is to make it as similar to regular Red as possible. While I highly doubt it can happen, it'd also be cool for it to also includes features like web equivalents for Red's View, Draw, Rich-Text, and VID dialects and a version of Red/System that can be compiled to WebAssembly.


# Example usage

```typescript
import Red from "./red";


/* this stuff is temporary */
Red.evalRed(`
	get: make native! [[
			"Returns the value a word refers to"
			word	[any-word! refinement! path! object!]
			/any    "If word has no value, return UNSET rather than causing an error"
			/case   "Use case-sensitive comparison (path only)"
			return: [any-type!]
		]
		get
	]
`);
Red.evalFile("./core/scalars.red");
Red.evalFile("./core/natives.red");
Red.evalFile("./core/actions.red");
Red.evalFile("./core/operators.red");
/* ------------------------------------- */

const fizzbuzz = `
Red [
	Title: "FizzBuzz example"
]

repeat i 100 [
	switch 0 [
		i % 15 [print "FizzBuzz"]
		i % 3  [print "Fizz"]
		i % 5  [print "Buzz"]
		0      [print mold i]
	]
]
`;

Red.evalCode(fizzbuzz);
```

# Running

## Locally
In order to run this locally, you'll need Node 12.13.1 or higher installed (I haven't tested it with any older versions yet) and TypeScript 3.9.2.

## In a browser
I have yet to actually test Red.js in a browser, but it should be fine as long as you aren't using IE or Firefox.


# Current limitations

- Because I didn't want to try recreating Red/System just yet, TypeScript is being used for development instead.
- Things that interact with the OS don't exist because web browsers don't do that.
- I have yet to benchmark anything, but there's a good chance that this is probably many times slower than the default implementation of Red.
- I'm currently only 1 person, so progress is gonna be kind of slow as long as it's just me.


# Notes

Please look at TODO.md