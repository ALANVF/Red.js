# Version 0.1.4 (in development)
- Implemented `reflect` action for `object!` and `map!`.
- Finished implementing `foreach`.
- Added more helper functions.
- Fixed quoting issues with `set-word!` and `set-path!`.
- Fixed quoting bugs for `get-word!` and `lit-word!` function arguments.
- Fixed `lit-word!` and `lit-path!` behavior.
- Removed multiline property from `string!`s because it wasn't needed.
- Fixed file error bug.
- Added `to-` helper functions.


# Version 0.1.3
- Reimplemented `vector!`s.
- Added `make` action for `vector!`s.
- Added `change` action.
- Fixed `insert` action.
- Correctly implement `copy` action.
- Improve `form`/`mold` internals.


# Version 0.1.2
- Removed `pre1` from the preprocessor.
- Reimplemented several `series!` types.
- Fixed `form`/`mold` for `binary!` values with an offset.
- Added `clear` action.
- Added `remove` action.
- Added `insert` action for `any-list!`, `any-path!`, and `any-string!`.
- Added `pad` and `repend` helper functions.
- Redid `email!`'s implementation.
- Finished implementing `append` for `any-list!`, `any-path!`, and `any-string!`.


# Version 0.1.1
- Fixed `>>>` (and tests/demo.red).


# Version 0.1.0
- Fixed `#include` directive.
- Fixed get-path/set-path bugs.
- Fixed `pick` bug.
- `print` now prints values correctly.
- Added `string!` comparison.
- Added bit-shift operators.
- Fixed a `case` bug.
- Added some testing scripts.
- Carets are now allowed in identifiers.
- Fixed `to block!` for strings and maps.
- Fixed a typo in the tokenizer.
- Fixed some `block!` and `paren!` actions.
- Fixed a thing related to `map!` keys.
- Added some actions for `pair!`s.
- Fixed `bitset!` internals.
- Fixed `form` for `refinement!` values.
- Fixed `mold` issues for:
	- `op!`
	- `native!`
	- `action!`
	- `function!`
	- `context!`
	- `object!`
	- `logic!`
- Added `form`/`mold` support for most remaining datatypes:
	- stringy types
	- `map!`
	- `unset!`
	- `binary!`
	- `issue!`
	- `time!`
	- `tuple!`
	- `percent!`
	- `hash!`
	- `vector!`
	- `bitset!`
	- `date!`
- Accidentally broke tests/demo.red (but I'll fix that later).


# Version 0.0.9
- Fixed `skip` bug.
- Added `extract` helper function.
- Fixed refinement arguments.
- Improved `poke` for `series!` types.
- Unified `percent!` behavior.
- Added `shift` native.
- Added trigonometric natives.
- Added `nan?` and `zero?` natives.
- Added more math natives.
- Added `absolute`, `negate`, and `power` actions.
- Added (partially incomplete) `make`/`to` actions for `integer!` and `float!`.
- Added some more helper functions.


# Version 0.0.8
- Added `negative?`, `positive?`, `max`, and `min` natives.
- Added support for `binary!` literals.
- Added support for `map!` literals.
- File loading now works in browser js.
- `do` now accepts `file!`s.
- `lit-word!` arguments that accept `unset!` now work.
- Added support for `tag!` literals.
- Added support for `date!` literals.


# Version 0.0.7
- Fixed `to` action.
- Reimplemented `char!` and `string!`.
- Added basic actions for `char!`.
- Fixed inconsistent `mold` behavior for `string!` and `char!`.
- Fixed `pick` and `poke` bugs.
- Added `unset` native.
- Added more utility functions.
- Fixed a context bug.
- Added `union` native (paritally).
- Added more supported types for `make block!`.
- Added `to` action for `block!`.
- Added `copy` action for `string!`.
- Fixed an issue where function refinements that didn't take any arguments would be ignored.
- Made the interactive help function better.
- Added all typesets.


# Version 0.0.6
- Added basic construction syntax support.
- Added `value?` native.
- Improved some code formatting.
- `number!` and `any-word!` are now located in `system/words`.
- Added `and`, `or`, and `xor` operations for `typeset!`s.
- `pair!`, `tuple!`, and `time!` no longer box their values (internal).


# Version 0.0.5
- Added `case` native.
- Added basic actions for `datatype!`.
- Fixed bug where `tail? []` would return false.
- Added basic actions for `path!`, `lit-path!`, `set-path!`, and `get-path!`.
- Added an interactive help function (although it's fairly incomplete).
- Added some of the built-in helper functions.
- Error messages related to missing type actions are now more descriptive.


# Version 0.0.4
- Fixed `set-path!`s (so now `a/1/2: 3` works).
- Fixed an issue where `path!`s were evaluated twice.
- Fixed various `paren!` bugs.
- `unset!`, `none!`, and `logic!` values are now treated as singletons to speed things up.


# Version 0.0.3	
- Restructured the main Red.js module.
- Switched to polymorphism for the type system.
- Fixed `foreach`, `repeat`, and several `series!`-related actions.
- (Mostly) unified `series!` types interally.
- Optimized a bit more code.
- Fixed bug where existing variables that were re-assigned in a new scope were accidently shadowed.


# Version 0.0.2
- Completely rewrote `context!`s.
- Fixed lots of scoping issues.
- Added the `object!` datatype.
- Fixed `path!`s (`set-path!`s are still kinda broken though).
- Optimized some code.


# Version 0.0.1
- Put Red.js on GitHub.
