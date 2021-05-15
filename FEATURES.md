# Guide
- Y = Implemented.
- N = Not implemented.
- P = Partially implemented.

# Datatypes
|                          | datatype | syntax | `make`/`to` | `form`/`mold` | `compare` | other actions |
|--------------------------|----------|--------|-------------|---------------|-----------|---------------|
| `datatype!`              | Y        | NA     | NA          | N             | N         | N             |
| `unset!`                 | Y        | NA     | N           | N             | N         | N             |
| `none!`                  | Y        | Y      | N           | N             | N         | N             |
| `logic!`                 | Y        | Y      | N           | N             | N         | N             |
| `block!`                 | Y        | Y      | N           | N             | N         | N             |
| `paren!`                 | Y        | Y      | N           | N             | N         | N             |
| `string!`                | Y        | P*     | N           | N             | N         | N             |
| `file!`                  | Y        | Y      | N           | N             | N         | N             |
| `url!`                   | Y        | Y      | N           | N             | N         | N             |
| `char!`                  | Y        | Y      | N           | N             | N         | N             |
| `integer!`               | Y        | Y      | N           | N             | N         | N             |
| `float!`                 | Y        | P**    | N           | N             | N         | N             |
| `word!`                  | Y        | Y      | N           | N             | N         | N             |
| `set-word!`              | Y        | Y      | N           | N             | N         | N             |
| `lit-word!`              | Y        | Y      | N           | N             | N         | N             |
| `get-word!`              | Y        | Y      | N           | N             | N         | N             |
| `refinement!`            | Y        | Y      | N           | N             | N         | N             |
| `issue!`                 | Y        | Y      | N           | N             | N         | N             |
| `native!`                | Y        | NA     | N           | N             | N         | N             |
| `action!`                | Y        | NA     | N           | N             | N         | N             |
| `op!`                    | Y        | NA     | N           | N             | N         | N             |
| `function!`              | Y        | NA     | N           | N             | N         | N             |
| `path!`                  | Y        | Y      | N           | N             | N         | N             |
| `lit-path!`              | Y        | Y      | N           | N             | N         | N             |
| `set-path!`              | Y        | Y      | N           | N             | N         | N             |
| `get-path!`              | Y        | Y      | N           | N             | N         | N             |
| `routine!`               | N        | NA     | N           | N             | N         | N             |
| `bitset!`                | Y        | NA     | N           | N             | N         | N             |
| `point!`                 | N        | NA     | N           | N             | N         | N             |
| `object!`                | Y        | NA     | N           | N             | N         | N             |
| `typeset!`               | Y        | NA     | N           | N             | N         | N             |
| `error!`                 | N        | NA     | N           | N             | N         | N             |
| `vector!`                | N        | NA     | N           | N             | N         | N             |
| `hash!`                  | P        | NA     | N           | N             | N         | N             |
| `pair!`                  | Y        | Y      | N           | N             | N         | N             |
| `percent!`               | Y        | Y      | N           | N             | N         | N             |
| `tuple!`                 | Y        | Y      | N           | N             | N         | N             |
| `map!`                   | Y        | Y      | N           | N             | N         | N             |
| `binary!`                | Y        | Y      | N           | N             | N         | N             |
| `time!`                  | Y        | Y      | N           | N             | N         | N             |
| `tag!`                   | Y        | Y      | N           | N             | N         | N             |
| `email!`                 | Y        | N***   | N           | N             | N         | N             |
| `handle!`                | N        | NA     | N           | N             | N         | N             |
| `date!`                  | Y        | N      | N           | N             | N         | N             |
| `port!`                  | N        | NA     | N           | N             | N         | N             |
| `image!`                 | N        | NA     | N           | N             | N         | N             |
| `money!`                 | N        | N      | N           | N             | N         | N             |
| `ref!`                   | Y        | Y      | N           | N             | N         | N             |

\* `raw-string!` literals are currently not supported.

\*\* NaN and infinity literals are currently not supported.

\*\*\* Parsing rule has been removed from the parser due to it causing a noticable slowdown during parsing.

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
| `func`              | N      |
| `function`          | N      |
| `does`              | N      |
| `has`               | N      |
| `switch`            | N      |
| `case`              | N      |
| `do`                | P      |
| `reduce`            | N      |
| `compose`           | N      |
| `get`               | Y      |
| `set`               | Y      |
| `print`             | Y*     |
| `prin`              | N**    |
| `equal?`            | N      |
| `not-equal?`        | N      |
| `strict-equal?`     | N      |
| `lesser?`           | N      |
| `greater?`          | N      |
| `lesser-or-equal?`  | N      |
| `greater-or-equal?` | N      |
| `same?`             | N      |
| `not`               | N      |
| `type?`             | N      |
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
| `break`             | N      |
| `continue`          | N      |
| `exit`              | N      |
| `return`            | N      |
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
| `transcode`         | P      |

\* For debugging use for now.
\*\* This can't be used in browsers.