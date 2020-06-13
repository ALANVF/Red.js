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
| `datatype!`              | Y        | NA     | NA          | Y             | P             |
| `unset!`                 | Y        | NA     | N           | Y             | N             |
| `none!`                  | Y        | P      | Y           | Y             | P             |
| `logic!`                 | Y        | P*     | N           | Y             | P             |
| `block!`                 | Y        | Y      | Y           | P**           | P             |
| `paren!`                 | Y        | Y      | Y           | P**           | P             |
| `string!`                | Y        | P      | N           | Y             | P             |
| `file!`                  | Y        | P      | N           | Y             | BI            |
| `url!`                   | Y        | PB     | N           | Y             | BI            |
| `char!`                  | Y        | Y      | N           | Y             | P             |
| `integer!`               | Y        | P      | P           | Y             | P             |
| `float!`                 | Y        | P***   | P           | Y             | P             |
| `context!`               | Y        | NA     | P           | P             | N             |
| `word!`                  | Y        | Y      | Y           | Y             | N             |
| `set-word!`              | Y        | Y      | Y           | Y             | N             |
| `lit-word!`              | Y        | Y      | Y           | Y             | N             |
| `get-word!`              | Y        | Y      | Y           | Y             | N             |
| `refinement!`            | Y        | Y      | N           | P             | N             |
| `issue!`                 | Y        | Y      | B           | B             | N             |
| `native!`                | Y        | NA     | P           | Y             | N             |
| `action!`                | Y        | NA     | P           | Y             | N             |
| `op!`                    | Y        | NA     | P           | P             | N             |
| `function!`              | Y        | NA     | P           | Y             | N             |
| `path!`                  | Y        | Y      | N           | Y             | PI            |
| `lit-path!`              | Y        | Y      | N           | Y             | PI            |
| `set-path!`              | Y        | Y      | N           | Y             | PI            |
| `get-path!`              | Y        | Y      | N           | Y             | PI            |
| `routine!`               | N        | NA     | N           | N             | N             |
| `bitset!`                | Y        | NA     | N           | N             | N             |
| `point!`                 | N        | NA     | N           | N             | N             |
| `object!`                | Y        | NA     | P           | Y             | N             |
| `typeset!`               | Y        | NA     | P           | Y             | P             |
| `error!`                 | N        | NA     | N           | N             | N             |
| `vector!`                | P        | NA     | N           | N             | PI            |
| `hash!`                  | P        | NA     | N           | N             | PI            |
| `pair!`                  | Y        | Y      | N           | Y             | P             |
| `percent!`               | Y        | Y      | N           | N             | N             |
| `tuple!`                 | Y        | Y      | N           | N             | N             |
| `map!`                   | Y        | Y      | N           | Y             | N             |
| `binary!`                | Y        | Y      | N           | N             | PI            |
| `time!`                  | Y        | Y      | N           | N             | N             |
| `tag!`                   | Y        | Y      | B           | Y             | P             |
| `email!`                 | Y        | B****  | B           | Y             | P             |
| `handle!`                | N        | NA     | N           | N             | N             |
| `date!`                  | Y        | Y      | N           | N             | N             |
| `port!`                  | N        | NA     | N           | N             | N             |
| `image!`                 | N        | NA     | N           | N             | BI            |
| `money!`                 | P        | B****  | N           | N             | N             |
| `ref!`                   | N        | N      | N           | N             | N             |

\* Only basic construction syntax is currently supported.

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
| `case`              | Y      |
| `do`                | P      |
| `reduce`            | P      |
| `compose`           | P      |
| `get`               | P      |
| `set`               | P      |
| `print`             | Y      |
| `prin`              | Y*     |
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
| `union`             | P      |
| `unique`            | N      |
| `intersect`         | N      |
| `difference`        | N      |
| `exclude`           | N      |
| `complement?`       | N      |
| `dehex`             | N      |
| `negative?`         | Y      |
| `positive?`         | Y      |
| `max`               | Y      |
| `min`               | Y      |
| `shift`             | Y      |
| `to-hex`            | N      |
| `sine`              | Y      |
| `cosine`            | Y      |
| `tangent`           | Y      |
| `arcsine`           | Y      |
| `arccosine`         | Y      |
| `arctangent`        | Y      |
| `arctangent2`       | Y      |
| `nan?`              | Y      |
| `zero?`             | Y      |
| `log-2`             | Y      |
| `log-10`            | Y      |
| `log-e`             | Y      |
| `exp`               | Y      |
| `square-root`       | Y      |
| `construct`         | N      |
| `value?`            | Y      |
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
| `unset`             | Y      |
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
| `transcode`         | N      |

\* This can't be used in browsers.