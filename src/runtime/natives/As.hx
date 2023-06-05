package runtime.natives;

import types.base._Block;
import types.base._String;
import types.base._Path;
import types.base._SeriesOf;
import types.*;

/* Implementation note: why on earth does red do this???
	a: [1 2 3]
	new-line next a true
	probe as block! as path! a
	;=> [1 
	;    2 3
	; ]
 *
 * This could easily be implemented by using Object.setPrototypeOf,
 * however every JS engine despises it so that is probably not the
 * best option. For now, it will just be hardcoded
*/

@:build(runtime.NativeBuilder.build())
class As {
	// The codegen for these is awful
	static final STRING_TYPES: std.Map<TypeKind, Class<_String>> = [
		DString => types.String,
		DFile => File,
		DUrl => Url,
		DTag => Tag,
		DEmail => Email,
		DRef => Ref
	];

	static final BLOCK_TYPES: std.Map<TypeKind, Class<_SeriesOf<Value, Value>>> = [
		DBlock => Block,
		DParen => Paren,
		DPath => Path,
		DLitPath => LitPath,
		DSetPath => SetPath,
		DGetPath => GetPath
	];

	public static function call(type: Value, spec: Value): Value {
		final kind = type._match(
			at({kind: k} is Datatype) => k,
			_ => type.TYPE_KIND
		);

		if(kind == spec.TYPE_KIND) {
			return spec;
		}
		
		spec._match(
			at(str is _String) => {
				STRING_TYPES[kind]._andOr(cls => {
					return (js.Syntax.code("new {0}({1}, {2})", cls, str.values, str.index) : Value);
				}, {
					throw "incompatible type!";
				});
			},
			at(block is Block | block is Paren) => {
				BLOCK_TYPES[kind]._andOr(cls => {
					// it ignores extra args anyways
					return (js.Syntax.code("new {0}({1}, {2}, {3})", cls, block.values, block.index, block.newlines) : Value);
				}, {
					throw "incompatible type!";
				});
			},
			at(path is _Path) => {
				BLOCK_TYPES[kind]._andOr(cls => {
					return (js.Syntax.code("new {0}({1}, {2})", cls, path.values, path.index) : Value);
				}, {
					throw "incompatible type!";
				});
			},
			_ => throw "incompatible type!"
		);
	}
}