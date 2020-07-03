# Red.js

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
Red.evalFile("./core/natives.red");
Red.evalFile("./core/actions.red");
Red.evalFile("./core/scalars.red");
Red.evalFile("./core/functions.red");
Red.evalFile("./core/operators.red");
Red.evalFile("./core/interactive.red");
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
		0      [print i]
	]
]
`;

Red.evalCode(fizzbuzz);
```

# Running

## Locally
In order to run this locally, you'll need:
- Node 12.13.1 or higher (I haven't tested it with any older versions yet)
- TypeScript 3.9.2 (`npm install -g typescript@3.9.2`).
- @types/node 13.13.5 (`npm install -g @types/node@13.13.5`).

Alternativly, you can `cd` to the project directory and do `npm install`.

## In a browser
I have yet to actually test Red.js using browser js, but it should be fine as long as you aren't using IE or Firefox.

You can also run the Red.js REPL (currently version 0.1.2) in your browser [right here](https://redjs-compiled-repl.theangryepicbanana.repl.run), although it will not always be up-to-date with the most recent version of Red.js immediately. This is currently hosted on [repl.it](https://repl.it/).


# Current limitations

- Because I didn't want to try recreating Red/System just yet, TypeScript is being used for development instead.
- Things that interact with the OSs don't exist because web browsers don't do that.
- I have yet to benchmark anything, but there's a good chance that this is probably many times slower than the default implementation of Red.
- I'm currently only 1 person, so progress is gonna be kind of slow as long as it's just me.


# FAQ

## Why not transpile to JS? Wouldn't that be easier and faster than using an interpreter?
This is sadly not possible due to the fundamental differences between Red and JS.
In order to support all of the meta-programming features that Red has, it'd be no
different transpiling to JS than just embedding the interpreter. There may be a
JS dialect of Red.js at some point in the future, but for now it will remain interpreted.

## Why do expressions in the REPL print out JS/JSON?
Because it's helpful to be able to easily inspect values when debugging. I'll probably
disable it some time in the future.

## Why isn't feature X in Red.js if it exists in normal Red?
Red.js is not a perfect replica of normal Red, as there are a large number of things
that JS cannot do within a browser that can normally be done in Red (due to browser limitations).
There *could* be features that only work when using native JS, but I would like to mainly
focus on features that work on both runtimes.

## Do you plan to implement dialects such as Red/System?
I already answered that.

## Will Red.js be able to compile to WebAssembly?
I also already answered that.

## Why TypeScript?
I would have much rather used something like TypedCoffeeScript, but it's dead and doesn't really have any tooling. In the end, this is still better than using something like Flow.

## What can I do to help with development?
Anything helps!


# Other notes

Please consider looking at TODO.md and FEATURES.md