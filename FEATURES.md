# Guide
- Y = Implemented.
- N = Not implemented.
- P = Partially implemented.

# Datatypes
|                          | datatype | syntax | `make` | `to` | `form` | `mold` | `compare` | other actions |
|--------------------------|----------|--------|--------|------|-----------------|-----------|---------------|
| `datatype!`              | Y        | NA     | NA     | NA   | N      | N      | N         | N             |
| `unset!`                 | Y        | NA     | Y      | Y    | Y      | Y      | N         | N             |
| `none!`                  | Y        | Y      | N      | N    | N      | N      | N         | N             |
| `logic!`                 | Y        | Y      | N      | N    | N      | N      | N         | N             |
| `block!`                 | Y        | Y      | N      | N    | N      | N      | N         | N             |
| `paren!`                 | Y        | Y      | N      | N    | N      | N      | N         | N             |
| `string!`                | Y        | P*     | N      | N    | N      | N      | N         | N             |
| `file!`                  | Y        | Y      | N      | N    | N      | N      | N         | N             |
| `url!`                   | Y        | Y      | N      | N    | N      | N      | N         | N             |
| `char!`                  | Y        | Y      | N      | N    | N      | N      | N         | N             |
| `integer!`               | Y        | Y      | N      | N    | N      | N      | P         | P             |
| `float!`                 | Y        | P**    | N      | N    | N      | N      | N         | N             |
| `word!`                  | Y        | Y      | N      | N    | N      | N      | N         | N             |
| `set-word!`              | Y        | Y      | N      | N    | N      | N      | N         | N             |
| `lit-word!`              | Y        | Y      | N      | N    | N      | N      | N         | N             |
| `get-word!`              | Y        | Y      | N      | N    | N      | N      | N         | N             |
| `refinement!`            | Y        | Y      | N      | N    | N      | N      | N         | N             |
| `issue!`                 | Y        | Y      | N      | N    | N      | N      | N         | N             |
| `native!`                | Y        | NA     | Y      | N    | N      | N      | N         | N             |
| `action!`                | Y        | NA     | Y      | N    | N      | N      | N         | N             |
| `op!`                    | Y        | NA     | Y      | N    | N      | N      | N         | N             |
| `function!`              | Y        | NA     | Y      | N    | N      | N      | N         | N             |
| `path!`                  | Y        | Y      | N      | N    | N      | N      | N         | N             |
| `lit-path!`              | Y        | Y      | N      | N    | N      | N      | N         | N             |
| `set-path!`              | Y        | Y      | N      | N    | N      | N      | N         | N             |
| `get-path!`              | Y        | Y      | N      | N    | N      | N      | N         | N             |
| `routine!`               | N        | NA     | N      | N    | N      | N      | N         | N             |
| `bitset!`                | Y        | NA     | N      | N    | N      | N      | N         | N             |
| `point!`                 | N        | NA     | N      | N    | N      | N      | N         | N             |
| `object!`                | Y        | NA     | N      | N    | N      | N      | N         | N             |
| `typeset!`               | Y        | NA     | Y      | N    | N      | N      | N         | N             |
| `error!`                 | N        | NA     | N      | N    | N      | N      | N         | N             |
| `vector!`                | N        | NA     | N      | N    | N      | N      | N         | N             |
| `hash!`                  | P        | NA     | N      | N    | N      | N      | N         | N             |
| `pair!`                  | Y        | Y      | N      | N    | N      | N      | N         | N             |
| `percent!`               | Y        | Y      | N      | N    | N      | N      | N         | N             |
| `tuple!`                 | Y        | Y      | N      | N    | N      | N      | N         | N             |
| `map!`                   | Y        | Y      | N      | N    | N      | N      | N         | N             |
| `binary!`                | Y        | Y      | N      | N    | N      | N      | N         | N             |
| `time!`                  | Y        | Y      | N      | N    | N      | N      | N         | N             |
| `tag!`                   | Y        | Y      | N      | N    | N      | N      | N         | N             |
| `email!`                 | Y        | N***   | N      | N    | N      | N      | N         | N             |
| `handle!`                | N        | NA     | N      | N    | N      | N      | N         | N             |
| `date!`                  | Y        | N      | N      | N    | N      | N      | N         | N             |
| `port!`                  | N        | NA     | N      | N    | N      | N      | N         | N             |
| `image!`                 | N        | NA     | N      | N    | N      | N      | N         | N             |
| `money!`                 | N        | N      | N      | N    | N      | N      | N         | N             |
| `ref!`                   | Y        | Y      | N      | N    | N      | N      | N         | N             |

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
| `print`             | Y*     |
| `prin`              | N**    |
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
| `bind`              | Y      |
| `in`                | Y      |
| `parse`             | N      |
| `union`             | P      |
| `unique`            | N      |
| `intersect`         | N      |
| `difference`        | N      |
| `exclude`           | N      |
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