package runtime.actions.datatypes;

import js.lib.Set;
import types.base.MathOp;
import types.base._ActionOptions;
import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base.IDatatype;
import types.Value;
import types.Typeset;
import types.Datatype;
import types.Block;
import types.Word;
import types.Logic;
import types.String;

import runtime.actions.datatypes.ValueActions.invalid;

class TypesetActions extends ValueActions<Typeset> {
	override function make(proto: Null<Typeset>, spec: Value) {
		return to(proto, spec);
	}

	override function to(proto: Null<Typeset>, spec: Value) {
		spec._match(
			at(ts is Typeset) => return ts,
			at(b is Block) => {
				return Typeset.ofAny([
					for(value in b) value._match(
						at(w is Word) => w.get(),
						_ => value
					)._match(
						at(dt is IDatatype) => dt,
						_ => runtime.natives.Type_q.of(value)
					)
				]);
			},
			_ => throw "bad"
		);
	}

	override function form(value: Typeset, buffer: String, arg: Null<Int>, part: Int) {
		final hasPart = arg != null;
		final types = value.types;
		var cnt = 0;
		buffer.appendLiteral("make typeset! [");
		part -= 15;
		for(dt in types) {
			if(hasPart && part < 0) return part;
			final name = dt.name;
			buffer.appendLiteral(name);
			buffer.appendChar(' '.code);
			part -= name.length - 1;
			cnt++;
		}
		if(cnt == 0) {
			buffer.appendChar(']'.code);
		} else {
			buffer.values[buffer.absLength - 1] = ']'.code;
		}
		return part;
	}

	override function mold(value: Typeset, buffer: String, _, _, _, arg: Null<Int>, part: Int, _) {
		return form(value, buffer, arg, part);
	}

	override function compare(value1: Typeset, value2: Value, op: ComparisonOp): CompareResult {
		value2._match(
			at(other is Typeset) => op._match(
				at( CEqual
				  | CSame
				  | CFind
				  | CStrictEqual
				  | CNotEqual
				) => {
					final types1 = value1.types;
					final types2 = other.types;
					
					if(types1.length != types2.length) return IsMore;
					for(type in types1) {
						if(!types2.has(type)) {
							return IsMore;
						}
					}
					return IsSame;
				},
				at(CSort | CCaseSort) => {
					return cast (value1.types.length - other.types.length).sign();
				},
				_ => return IsInvalid
			),
			_ => return IsInvalid
		);
	}

	static function doBitwise(left: Typeset, right: Value, op: MathOp) {
		final set1 = left.types;
		final set2 = right._match(
			at(t is Typeset) => t.types,
			at(d is Datatype) => new util.Set([d]),
			_ => invalid()
		);

		return new Typeset(op._match(
			at(OUnion | OOr) => {
				new util.Set(js.Syntax.code("[...{0}, ...{1}]", set1, set2));
			},
			at(OIntersect | OAnd) => {
				set1.filter(d -> set2.has(d));
			},
			at(ODifference | OXor) => {
				final res = set1.copy();

				for(d in set2) {
					if(res.has(d)) res.remove(d);
					else res.add(d);
				}

				res;
			},
			at(OExclude) => {
				set1.filter(d -> !set2.has(d));
			},
			_ => invalid()
		));
	}


	/*-- Bitwise actions --*/

	override function complement(value: Typeset) {
		return Typeset.of([
			for(p in Runtime.DATATYPES)
				if(!value.types.has(p._2)) p._2
		]);
	}

	override function and(value1: Typeset, value2: Value) {
		return doBitwise(value1, value2, OAnd);
	}

	override function or(value1: Typeset, value2: Value) {
		return doBitwise(value1, value2, OOr);
	}

	override function xor(value1: Typeset, value2: Value) {
		return doBitwise(value1, value2, OXor);
	}

	
	/*-- Series actions --*/

	override function find(typeset: Typeset, value: Value, options: AFindOptions) {
		return value._match(
			at(type is Datatype) => return Logic.fromCond(typeset.types.has(type)),
			_ => invalid()
		);
	}
}