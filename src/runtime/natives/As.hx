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
	static final STRING_TYPES = Dict.of(([
		TypeKind.DString => types.String,
		TypeKind.DFile => File,
		TypeKind.DUrl => Url,
		TypeKind.DTag => Tag,
		TypeKind.DEmail => Email,
		TypeKind.DRef => Ref
	] : std.Map<TypeKind, Class<_String>>));

	static final BLOCK_TYPES = Dict.of(([
		TypeKind.DBlock => Block,
		TypeKind.DParen => Paren,
		TypeKind.DPath => Path,
		TypeKind.DLitPath => LitPath,
		TypeKind.DSetPath => SetPath,
		TypeKind.DGetPath => GetPath
	] : std.Map<TypeKind, Class<_SeriesOf<Value, Value>>>));

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