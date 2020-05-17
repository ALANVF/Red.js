# Guide
- Y = Implemented.
- N = Not implemented.
- P = Partially implemented.
- IB = Implemented, but broken.
- PB = Partially implemented, but broken.
- BI = Broken because of inheritance.
- PI = Partially broken because of inheritance.
- B  = Just broken.

# Datatypes
|                          | datatype | syntax | `make`/`to` | `form`/`mold` | other actions |
|--------------------------|----------|--------|-------------|---------------|---------------|
| `datatype!`              | Y        | NA     | NA          | N             | N             |
| `unset!`                 | Y        | NA     | N           | N             | N             |
| `none!`                  | Y        | P*     | Y           | Y             | P             |
| `logic!`                 | Y        | P*     | N           | Y             | P             |
| `block!`                 | Y        | Y      | P           | P**           | P             |
| `paren!`                 | Y        | Y      | B           | B             | PI            |
| `string!`                | Y        | Y      | N           | Y             | P             |
| `file!`                  | Y        | P      | N           | N             | BI            |
| `url!`                   | Y        | PB     | N           | N             | BI            |
| `char!`                  | Y        | Y      | N           | N             | N             |
| `integer!`               | Y        | P      | N           | Y             | P             |
| `float!`                 | Y        | P***   | N           | Y             | P             |
| `context!`               | Y        | NA     | P           | P             | N             |
| `word!`                  | Y        | Y      | p           | Y             | N             |
| `set-word!`              | Y        | Y      | P           | Y             | N             |
| `lit-word!`              | Y        | Y      | P           | Y             | N             |
| `get-word!`              | Y        | Y      | P           | Y             | N             |
| `refinement!`            | Y        | Y      | N           | P             | N             |
| `issue!`                 | Y        | Y      | B           | B             | N             |
| `native!`                | Y        | NA     | P           | Y             | N             |
| `action!`                | Y        | NA     | P           | Y             | N             |
| `op!`                    | Y        | NA     | P           | P             | N             |
| `function!`              | Y        | NA     | P           | Y             | N             |
| `path!`                  | Y        | Y      | N           | N             | PI            |
| `lit-path!`              | Y        | Y      | N           | N             | PI            |
| `set-path!`              | Y        | Y      | N           | N             | PI            |
| `get-path!`              | Y        | Y      | N           | N             | PI            |
| `routine!`               | N        | NA     | N           | N             | N             |
| `bitset!`                | Y        | NA     | N           | N             | N             |
| `point!`                 | N        | NA     | N           | N             | N             |
| `object!`                | Y        | NA     | P           | Y             | N             |
| `typeset!`               | Y        | NA     | P           | Y             | N             |
| `error!`                 | N        | NA     | N           | N             | N             |
| `vector!`                | P        | NA     | N           | N             | PI            |
| `hash!`                  | P        | NA     | N           | N             | PI            |
| `pair!`                  | Y        | Y      | N           | N             | N             |
| `percent!`               | Y        | Y      | N           | N             | N             |
| `tuple!`                 | Y        | Y      | N           | N             | N             |
| `map!`                   | Y        | PB     | N           | N             | N             |
| `binary!`                | Y        | PB     | N           | N             | PI            |
| `time!`                  | Y        | Y      | N           | N             | N             |
| `tag!`                   | Y        | N      | B           | B             | BI            |
| `email!`                 | Y        | B****  | B           | B             | BI            |
| `handle!`                | N        | NA     | N           | N             | N             |
| `date!`                  | Y        | N      | N           | N             | N             |
| `port!`                  | N        | NA     | N           | N             | N             |
| `image!`                 | N        | NA     | N           | N             | BI            |
| `money!`                 | P        | B****  | N           | N             | N             |

\* Construction syntax is currently not supported.

\*\* Newlines are currently not preserved.

\*\*\* NaN and infinity literals are currently not supported.

\*\*\*\* Parsing rule has been removed from the parser due to it causing a noticable slowdown during parsing.

# Natives
|                     | status |
|---------------------|--------|
| `if`                | Y      |
| `unless`            | Y      |
| `either`            | Y      |
| `any`               | Y      |
| `all`               | Y      |
| `while`             | Y      |
| `until`             | Y      |
| `loop`              | Y      |
| `repeat`            | Y      |
| `forever`           | Y      |
| `foreach`           | P      |
| `forall`            | N      |
| `remove-each`       | N      |
| `func`              | Y      |
| `function`          | N      |
| `does`              | Y      |
| `has`               | Y      |
| `switch`            | PB     |
| `case`              | N      |
| `do`                | P      |
| `reduce`            | P      |
| `compose`           | P      |
| `get`               | P      |
| `set`               | P      |
| `print`             | P*     |
| `prin`              | Y**    |
| `equal?`            | Y      |
| `not-equal?`        | Y      |
| `strict-equal?`     | Y      |
| `lesser?`           | Y      |
| `greater?`          | Y      |
| `lesser-or-equal?`  | Y      |
| `greater-or-equal?` | Y      |
| `same?`             | Y      |
| `not`               | Y      |
| `type?`             | Y      |
| `stats`             | N      |
| `bind`              | N      |
| `in`                | N      |
| `parse`             | N      |
| `union`             | N      |
| `unique`            | N      |
| `intersect`         | N      |
| `difference`        | N      |
| `exclude`           | N      |
| `complement?`       | N      |
| `dehex`             | N      |
| `negative?`         | N      |
| `positive?`         | N      |
| `max`               | N      |
| `min`               | N      |
| `shift`             | N      |
| `to-hex`            | N      |
| `sine`              | N      |
| `cosine`            | N      |
| `tangent`           | N      |
| `arcsine`           | N      |
| `arccosine`         | N      |
| `arctangent`        | N      |
| `arctangent2`       | N      |
| `nan?`              | N      |
| `zero?`             | N      |
| `log-2`             | N      |
| `log-10`            | N      |
| `log-e`             | N      |
| `exp`               | N      |
| `square-root`       | N      |
| `construct`         | N      |
| `value?`            | N      |
| `try`               | N      |
| `uppercase`         | N      |
| `lowercase`         | N      |
| `as-pair`           | N      |
| `break`             | Y      |
| `continue`          | Y      |
| `exit`              | Y      |
| `return`            | Y      |
| `throw`             | N      |
| `catch`             | N      |
| `extend`            | N      |
| `debase`            | N      |
| `enbase`            | N      |
| `to-local-file`     | N      |
| `wait`              | N      |
| `checksum`          | N      |
| `unset`             | N      |
| `new-line`          | N      |
| `new-line?`         | N      |
| `context?`          | N      |
| `set-env`           | N      |
| `get-env`           | N      |
| `list-env`          | N      |
| `now`               | N      |
| `sign?`             | N      |
| `as`                | N      |
| `call`              | N      |
| `size?`             | N      |
| `browse`            | N      |
| `compress`          | N      |
| `decompress`        | N      |
| `recycle`           | N      |

\* This currently only prints out `string!`s as regular text (mainly for debugging).

\*\* This can't be used in browsers.