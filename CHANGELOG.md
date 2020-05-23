# Version 0.0.7 (currently in development)
- Fixed `to` action.
- Reimplemented `char!` and `string!`.
- Added basic actions for `char!`.
- Fixed inconsistent `mold` behavior for `string!` and `char!`.
- Fixed `pick` bug.
- Added `unset` native.


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