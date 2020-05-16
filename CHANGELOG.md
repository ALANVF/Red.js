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