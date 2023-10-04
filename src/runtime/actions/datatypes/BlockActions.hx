package runtime.actions.datatypes;

import types.Word;
import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.base._Path;
import types.base._Block;
import types.base._BlockLike;
import types.Value;
import types.Block;
import types.Integer;
import types.Float;
import types.Pair;
import types.Logic;
import types.Object;
import types.Map;
import types.String;
import types.Typeset;

import runtime.actions.Form;
import runtime.actions.Mold;

import runtime.actions.datatypes.ValueActions.invalid;

class BlockActions<This: _Block = Block> extends _BlockLikeActions<This> {
	private function makeThis(values: Array<Value>, ?index: Int, ?newlines: util.Set<Int>): This {
		return cast new Block(values, index, newlines);
	}

	static function moldEach(
		blk: _Block, buffer: String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		indent: Int
	) {
		final head = blk.index;
		var value = head;
		final tail = blk.absLength;

		var lf = false;
		var depth = 0;

		Cycles.push(blk.values);

		while(value < tail) {
			if(arg != null && part <= 0) {
				Cycles.pop();
				return part;
			}
			depth++;
			if(!isFlat && blk.hasNewline(value)) {
				if(!isOnly && value == head) {
					lf = true;
					indent++;
				}
				if(!isOnly || value != head) {
					buffer.appendChar('\n'.code);
					part--;
				}
				for(_ in 0...indent) buffer.appendLiteral("    ");
				part -= indent * 4;
			}

			part = Mold._call(blk.values[value], buffer, false, isAll, isFlat, arg, part, indent);

			if(depth > 0) {
				buffer.appendChar(' '.code);
				part--;
			}

			depth--;
			value++;
		}
		Cycles.pop();

		if(value != head) {
			buffer.values.pop();
			part++;
		}
		if(lf) {
			indent--;
			buffer.appendChar('\n'.code);
			for(_ in 0...indent) buffer.appendLiteral("    ");
			part -= (indent * 4) + 1;
		}

		return part;
	}


	override function make(proto: Null<This>, spec: Value): This {
		return spec._match(
			at(_ is Integer | _ is Float) => makeThis([]),
			at(b is _BlockLike) => {
				makeThis(b.cloneValues(), 0, b._match(
					at({newlines: nl} is _Block) => nl?.copy(),
					_ => null
				));
			},
			at(o is Object) => cast ObjectActions._reflect(o, Words.BODY),
			at(m is Map) => throw "todo",
			//Vector
			_ => invalid()

		);
	}

	override function to(proto: Null<This>, spec: Value) {
		return spec._match(
			at(o is Object) => cast ObjectActions._reflect(o, Words.BODY),
			at(m is Map) => throw "todo",
			//Vector
			//String
			at(t is Typeset) => makeThis(cast t.types.toArray()),
			at(b is _BlockLike) => {
				makeThis(b.cloneValues(), 0, b._match(
					at({newlines: nl} is _Block) => nl?.copy(),
					_ => null
				));
			},
			_ => makeThis([spec])
		);
	}

	override function form(value: This, buffer: String, arg: Null<Int>, part: Int) {
		Util.detuple([part, @var cycle], Cycles.detect(value, buffer, part, false));
		if(cycle) return part;

		var c = 0;

		Cycles.push(value.values);
		
		for(i in value.index...value.absLength) {
			if(arg != null && part <= 0) {
				Cycles.pop();
				return part;
			}
			part = Form._call(value.values[i], buffer, arg, part);

			if(i + 1 == value.absLength) {
				c = buffer.length == 0 ? 0 : buffer.values.at(-1);
			}

			if(!(c == '\n'.code || c == '\r'.code || c == '\t'.code)) {
				buffer.appendChar(' '.code);
				part--;
			}
		}
		Cycles.pop();
		return part;
	}

	override function mold(
		value: This, buffer: String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		indent: Int
	) {
		Util.detuple([part, @var cycle], Cycles.detect(value, buffer, part, true));
		if(cycle) return part;

		if(!isOnly) {
			buffer.appendChar('['.code);
			part--;
		}
		part = moldEach(value, buffer, isOnly, isAll, isFlat, arg, part, indent);

		if(!isOnly) {
			buffer.appendChar(']'.code);
			part--;
		}
		return part;
	}

	override function evalPath(
		parent: This, element: Value, value: Null<Value>,
		path: Null<_Path>, gparent: Null<Value>, pItem: Null<Value>,
		index: Int,
		isCase: Bool, isGet: Bool, isTail: Bool
	): Value {
		return element._match(
			at(i is Integer) => {
				value._andOr(value => {
					poke(parent, i, value);
				}, {
					pick(parent, i);
				});
			},
			_ => throw "todo"
		);
	}

	/*-- Series actions --*/

	override function copy(series: This, options: ACopyOptions): This {
		final node = series.values;
		final res = super.copy(series, options);
		if(options.deep) {
			if(Cycles.find(node)) throw "bad";
			Cycles.push(node);
			for(i in 0...res.absLength) {
				res.values[i]._match(
					at(slot is types.base._SeriesOf<Value, Any>) => {
						res.values[i] = runtime.actions.Copy.call(res.values[i], {deep: true});
					},
					_ => {}
				);
			}
			Cycles.pop();
		}
		
		return res;
	}

	override function take(series: This, options: ATakeOptions): Value {
		return super.take(series, options)._match(
			at(blk is _BlockLike) => {
				final s = blk.values;

				if(options.deep) {
					for(i in 0...blk.absLength) {
						s[i]._match(
							at(slot is types.base._SeriesOf<Value, Any>) => {
								s[i] = runtime.actions.Copy.call(slot, {deep: true});
							},
							_ => {}
						);
					}
				}
				
				if(options.part == null) {
					blk.copy();
				} else {
					blk;
				}
			},
			at(res) => res
		);
	}
}