# Guide
- Y = Implemented.
- N = Not implemented.
- P = Partially implemented.

# Datatypes
|                          | datatype | syntax | `make` | `to` | `form` | `mold` | `compare` | other actions |
|--------------------------|----------|--------|--------|------|--------|--------|-----------|---------------|
| `datatype!`              | Y        | NA     | NA     | NA   | Y      | Y      | Y         | N             |
| `unset!`                 | Y        | NA     | Y      | Y    | Y      | Y      | Y         | N             |
| `none!`                  | Y        | Y      | Y      | Y    | Y      | Y      | Y         | N             |
| `logic!`                 | Y        | Y      | Y      | Y    | Y      | Y      | Y         | P             |
| `block!`                 | Y        | Y      | N      | N    | Y      | Y      | Y         | P             |
| `paren!`                 | Y        | Y      | N      | N    | Y      | Y      | Y         | P             |
| `string!`                | Y        | Y*     | N      | N    | Y      | Y      | P         | P             |
| `file!`                  | Y        | Y      | N      | N    | Y      | Y      | P         | P             |
| `url!`                   | Y        | Y      | N      | N    | Y      | Y      | P         | P             |
| `char!`                  | Y        | Y      | Y      | P    | Y      | Y      | Y         | P             |
| `integer!`               | Y        | Y      | Y      | P    | Y      | Y      | P         | P             |
| `float!`                 | Y        | Y      | Y      | P    | P      | Y      | P         | P             |
| `word!`                  | Y        | Y      | N      | N    | Y      | Y      | Y         | N             |
| `set-word!`              | Y        | Y      | N      | N    | Y      | Y      | Y         | N             |
| `lit-word!`              | Y        | Y      | N      | N    | Y      | Y      | Y         | N             |
| `get-word!`              | Y        | Y      | N      | N    | Y      | Y      | Y         | N             |
| `refinement!`            | Y        | Y      | N      | N    | Y      | Y      | Y         | N             |
| `issue!`                 | Y        | Y      | N      | N    | Y      | Y      | Y         | N             |
| `native!`                | Y        | NA     | Y      | N    | Y      | Y      | Y         | Y             |
| `action!`                | Y        | NA     | Y      | N    | Y      | Y      | Y         | Y             |
| `op!`                    | Y        | NA     | Y      | N    | Y      | Y      | Y         | Y             |
| `function!`              | Y        | NA     | Y      | N    | Y      | Y      | Y         | Y             |
| `path!`                  | Y        | Y      | N      | N    | Y      | Y      | Y         | P             |
| `lit-path!`              | Y        | Y      | N      | N    | Y      | Y      | Y         | P             |
| `set-path!`              | Y        | Y      | N      | N    | Y      | Y      | Y         | P             |
| `get-path!`              | Y        | Y      | N      | N    | Y      | Y      | Y         | P             |
| `routine!`               | NA       | NA     | N      | N    | N      | N      | N         | N             |
| `bitset!`                | Y        | NA     | Y      | Y    | Y      | Y      | Y         | Y             |
| `point!`                 | N        | NA     | N      | N    | N      | N      | N         | N             |
| `object!`                | Y        | NA     | Y      | N    | Y      | Y      | Y         | P             |
| `typeset!`               | Y        | NA     | Y      | Y    | Y      | Y      | Y         | Y             |
| `error!`                 | Y        | NA     | N      | N    | N      | N      | Y         | N             |
| `vector!`                | N        | NA     | N      | N    | N      | N      | N         | N             |
| `hash!`                  | P        | NA     | N      | N    | Y      | Y      | Y         | P             |
| `pair!`                  | Y        | Y      | P      | Y    | Y      | Y      | Y         | P             |
| `percent!`               | Y        | Y      | Y      | P    | Y      | Y      | P         | P             |
| `tuple!`                 | Y        | Y      | Y      | P    | Y      | Y      | Y         | P             |
| `map!`                   | Y        | Y      | N      | N    | N      | N      | N         | N             |
| `binary!`                | Y        | Y      | N      | N    | Y      | Y      | Y         | P             |
| `time!`                  | Y        | Y      | Y      | P    | Y      | Y      | P         | P             |
| `tag!`                   | Y        | Y      | N      | N    | Y      | Y      | P         | P             |
| `email!`                 | Y        | N**    | N      | N    | Y      | Y      | P         | P             |
| `handle!`                | NA       | NA     | N      | N    | N      | N      | N         | N             |
| `date!`                  | Y        | N      | N      | N    | N      | N      | N         | N             |
| `port!`                  | N        | NA     | N      | N    | N      | N      | N         | N             |
| `image!`                 | N        | NA     | N      | N    | N      | N      | N         | N             |
| `money!`                 | N        | N**    | N      | N    | N      | N      | N         | N             |
| `ref!`                   | Y        | Y      | N      | N    | Y      | Y      | P         | P             |

\* `raw-string!` literals are slightly more permissive than in Red's normal lexer.

\*\* Parsing rule has been removed from the parser due to it causing a noticable slowdown during parsing.

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
| `foreach`           | Y      |
| `forall`            | Y      |
| `remove-each`       | Y      |
| `func`              | Y      |
| `function`          | N      |
| `does`              | Y      |
| `has`               | Y      |
| `switch`            | Y      |
| `case`              | Y      |
| `do`                | P      |
| `reduce`            | P      |
| `compose`           | P      |
| `get`               | Y      |
| `set`               | Y      |
| `print`             | Y      |
| `prin`              | N*     |
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
| `stats`             | NA     |
| `bind`              | Y      |
| `in`                | Y      |
| `parse`             | N      |
| `union`             | P      |
| `unique`            | P      |
| `intersect`         | P      |
| `difference`        | P      |
| `exclude`           | P      |
| `complement?`       | Y      |
| `dehex`             | Y      |
| `enhex`             | Y      |
| `negative?`         | Y      |
| `positive?`         | Y      |
| `max`               | Y      |
| `min`               | Y      |
| `shift`             | Y      |
| `to-hex`            | Y      |
| `sine`              | Y      |
| `cosine`            | Y      |
| `tangent`           | Y      |
| `arcsine`           | Y      |
| `arccosine`         | Y      |
| `arctangent`        | Y      |
| `arctangent2`       | Y      |
| `NaN?`              | Y      |
| `zero?`             | Y      |
| `log-2`             | Y      |
| `log-10`            | Y      |
| `log-e`             | Y      |
| `exp`               | Y      |
| `square-root`       | Y      |
| `construct`         | Y      |
| `value?`            | Y      |
| `try`               | P      |
| `uppercase`         | Y      |
| `lowercase`         | Y      |
| `as-pair`           | Y      |
| `as-money`          | N      |
| `break`             | Y      |
| `continue`          | Y      |
| `exit`              | Y      |
| `return`            | Y      |
| `throw`             | Y      |
| `catch`             | Y      |
| `extend`            | Y      |
| `debase`            | N      |
| `enbase`            | N      |
| `to-local-file`     | N*     |
| `wait`              | N      |
| `checksum`          | N      |
| `unset`             | Y      |
| `new-line`          | Y      |
| `new-line?`         | Y      |
| `context?`          | Y      |
| `set-env`           | N*     |
| `get-env`           | N*     |
| `list-env`          | N*     |
| `now`               | P      |
| `sign?`             | P      |
| `as`                | Y**    |
| `call`              | N*     |
| `size?`             | N      |
| `browse`            | N      |
| `compress`          | N*     |
| `decompress`        | N*     |
| `recycle`           | NA     |
| `transcode`         | P      |

\* This can't be used in browsers.

\*\* See implementation for details