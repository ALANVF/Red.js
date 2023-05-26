# Red.js

Red.js is a web runtime for the [Red programming language](https://www.red-lang.org/) that allows you use Red right in your browser. Although it's currently very incomplete, the end goal is to make it as similar to regular Red as possible. While I highly doubt it can happen, it'd also be cool for it to also includes features like web equivalents for Red's View, Draw, Rich-Text, and VID dialects and a version of Red/System that can be compiled to WebAssembly.


# STATUS UPDATE
Red.js is currently being converted from TypeScript to Haxe due to a variety of reasons:
- I can't stand TypeScript's type system and poor Babel support. I'd love to use stuff like the do-expressions Babel plugin, but the IDE itself doesn't even support it (I did fix the highlighting mode (locally) just for fun though). Haxe is strictly-typed, doesn't require polyfill, and has the benefits of do-expressions builtin.
- [It's been pointed out to me](https://gitter.im/red/red.js?at=5f38e2acb7818b3998fdef69) that I did not implement contexts correctly, and it'd be really hard to reimplement them at this point with the existing code (see below).
- Despite my efforts, the codebase is pretty messy, cluttered, and poorly-organized. A fresh start means that it can be completely restructured.
- Although the focus of Red.js is to be able to run Red in JavaScript, Haxe can compile to more targets outside of JS, which could prove to be helpful at some point.

I am keeping the old code in the `old` folder for future reference until the transition to Haxe is complete.


# Example usage

NYI


# Running

## Locally
In order to run this locally, you'll need:
- Haxe 4.3.1 (or higher)
- Some version of Node

1) Run `haxe build.hxml` to build Red.js
2) Run `node bin/main.js` to start the Red.js REPL


## In a browser

NYI


# Current limitations

- Because I didn't want to try recreating Red/System just yet, Haxe is being used for development instead.
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
that Haxe/JS cannot do within a browser that can normally be done in Red (due to browser limitations).
There *could* be features that only work when using Node or a different Haxe target, but
I would like to mainly focus on features that work on both runtimes.


## Do you plan to implement dialects such as Red/System?
I already answered that.


## Will Red.js be able to compile to WebAssembly?
I also already answered that.


## Why Haxe?
TypeScript is... annoying. It doesn't support nominal typing (even for classes!), lacks real pattern matching, and it's honestly just as unproductive as the language that it's built on.

Haxe, on the other hand, is a very powerful language that not only compiles to JS, but also fixes pretty much everything that I don't like about TS. These things include:
- strict typing
- pattern matching (well, it doesn't have destructuring (yet), but it's otherwise fine)
- real/better tagged unions
- (type-safe) macros
- everything is an expression, which can greatly reduce code size

That being said, Haxe does have a few downsides:
- requires more boilerplate due to its small standard library
- null safety is meh (you can't overload postifx `!` without macros??)
- no array splats (`...`)
- no type refinement/narrowing
- no polymorphic `this` type
- pattern matching extractors exponentially increase codegen (...bug?)
- function overloading is kinda painful
- no untagged unions

Despite these issues, Haxe has been much nicer to work with, and gave me a chance to fix a lot of things that I had originally implemented incorrectly.
I've made some macros to help with some of these things, and others have been accepted at the latest Haxe evolution meeting, so I'm hoping that will make the experience better at some point soon.


## What can I do to help with development?
Anything helps!


# Other notes

Please consider looking at TODO.md and FEATURES.md