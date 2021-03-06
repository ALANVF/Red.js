TL;DR:
- Fix bugs.
- Redo bad/incomplete code.
- Finish implementing features.

Finish very soon:
- Finish implementing `find`.
- Add more `series!` actions.
- Add the `error!` type.
- Fix relative paths when loading files.
- Add `compare` action for all datatypes.
- Add `am`/`pm` suffixes for `time!` values.

Finish somewhat soon:
- Add some tests.
- Implement actions for more datatypes.
- Add newline markers in blocks (will require rewriting many things).
- Give functions special contexts so that `self` can be used in a function inside an object/context.
- Switch from using unions to interfaces for the type system.
- Reimplement `money!`.
- Add Red's newly implemented `ref!` type.
- Improve help functions.

Finish sometime:
- Finish all natives.
- Finish all actions.
- Add builtin utility functions (in-progress).
- Implement remaining datatypes.
- Add more rules to the parser (mostly done).
- Make error messages way more helpful/descriptive.
- Add the Parse dialect.
- Figure out what to do with the `routine!` type.
- Add the `reactor!`/`deep-reactor!` type (I don't even know where to start with that one).
- Add the `port!` type (and actors and stuff).
- Add extra stuff the the global system object.
- Finish implementing macros.

Finish if I'm still bored:
- Add support for interacting with the DOM (and maybe have it act like Red/View).
- Make a JS ffi (and maybe use Rebol's `library!` type for it).
- Make a variant of Red/System but for js (kinda like the previous thing).
- Add a binary language mode like what Red has.
- Add the DELECT native from Rebol.
- Add the utype! type from Rebol (although it's not completely finished).
- Implement Rebol's module system (along with the `module!` type).
- Optimize the runtime a ton.
- Optimize the runtime even more.
- Optimize the parser as well.

Finish if I'm still bored:
- Make a C ffi (and maybe use Rebol's `library!` type for it).
- Allow compiling to/running on WebAssembly.

Things already done:
- Completely redo the tokenizer (might also redo it a third time).
- Use RawDatatype for types instead of type constructors (ew).
- Fix get/lit word parameters in new natives and actions.
- Add support for running .red files (make sure to detect the header!).
- Add support for user-defined functions.
- Make the API's naming conventions less horrible.
- Completely redo `context!`s.
- Fix accessing stuff in the global system object.
- Fix `series!`-related functions because I somehow broke them by accident.
- `a: [none] a/1` should not return a `none!`.
- Fix path stuff for other things supporting path access:
	- Fix path assignments that are longer than 2 values.
- ~~`series!` actions such as `at` and `skip` should not copy the original `series!`.~~
- Add (at least basic) support for construction syntax.
- Stop boxing compound natives such as `pair!` and `time!`.
- Fix `to` (internal issue).
- Reimplement `char!` and `string!`.
- Implement basic actions for `char!`.
- Fix function arguments that accept `unset!`.
- Add support for `map!`, `binary!`, and `date!` literals.
- Fix refinements for natives and actions.
- Allow including files.
- Unify `percent!` behavior.
- Implement (more) math natives.
- Add bit-shift operators.
- Fix stringy types like `file!` and `tag!`.
- Remove `pre1` from the preprocessor.
- Redo/reimplement everything related to vectors.
	- The current implementation has recently started to backfire due to TypeScript's broken "weak structural typing" in type unions.
	- Vector docs: [here](https://github.com/red/red/wiki/%5BDOC%5D-Comparison-of-aggregate-values-%28block%21-vector%21-object%21-hash%21-map%21%29#vector).
	- Might use JS' typed arrays to increase efficiency.
- Change `form` and `mold` to use a string ref instead of a string array.
- Fix any quoting bugs (should be *all* quoting bugs, as many exist for function arguments).
	- Quoting specs: https://github.com/meijeru/red.specs-public/blob/master/specs.adoc#741-function-type
- Remove the "multiline" property from `string!`s because it's not actually needed.
	- `form` and `mold` implementations need to be changed accordingly.