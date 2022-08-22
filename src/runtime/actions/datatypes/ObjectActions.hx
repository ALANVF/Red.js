package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.base._Block;
import types.base.Context;
import types.base._SeriesOf;
import types.base._Path;
import types.base._String;
import types.base._AnyWord;
import types.base._Number;
import types.Value;
import types.Object;
import types.Block;
import types.Paren;
import types.Function;

import runtime.actions.Copy;

class ObjectActions extends ValueActions<Object> {
	static function duplicate(src: Context, dst: Context, copy: Bool) {
		final from = src.values;
		final to = dst.values;

		for(i => value in from) {
			if(value is types.base.ISeriesOf) {
				final newValue = Copy.call(value, {deep: true});
				to[i] = newValue;

				newValue._match(
					at(blk is _Block) => {
						dst.bind(blk, true);
					},
					_ => {}
				);
			} else {
				if(copy) {
					to[i] = value;
				}
			}
		}
	}

	static function extend(ctx: Context, spec: Context, obj: Object) {
		final syms = spec.symbols;
		final vals = spec.values;
		final numSyms = syms.length;

		final baseSyms = ctx.symbols;
		final numBaseSyms = baseSyms.length;
		final baseVals = ctx.values;

		// 1st pass
		for(i => sym in syms) {
			ctx.addOrSetWord(sym, vals[i]);
		}

		// 2nd pass
		for(i in 0...numSyms) {
			final value = baseVals[i];
			value._match(
				at(_ is _SeriesOf) => {
					baseVals[i] = Copy.call(value, {deep: true});
				},
				at(fn is Function) => {
					baseVals[i] = rebind(fn, ctx, obj);
				},
				_ => {}
			);
		}

		return baseSyms.length > numBaseSyms;
	}

	static function rebind(fn: Function, ctx: Context, obj: Object) {
		final newCtx = new Context(fn.ctx.symbols, fn.ctx.values);
		final blk = Copy.block(fn.body, true, true);

		ctx.bind(blk, true);
		newCtx.bind(blk, false);
		
		return new Function(newCtx, fn.doc, fn.params, fn.refines, fn.retSpec, blk);
	}


	override function make(proto: Null<Object>, spec: Value) {
		// TODO: on-set-defined? and on-deep?

		final hasProto = proto != null;
		final obj = hasProto ? copy(proto, {deep: true}) : new Object(null, 0);

		spec._match(
			at(obj2 is Object) => {
				final changed = extend(obj.ctx, proto.ctx, obj);
				obj.classID = if(changed) ++Object.maxID else proto.classID;
			},
			at(block is Block) => {
				final isNew = obj.ctx.collectSetWords(block);

				obj.ctx.bind(block, true);
				if(hasProto) duplicate(proto.ctx, obj.ctx, false);
				runtime.natives.Do.evalValues(block);

				if(isNew || !hasProto) {
					obj.classID = ++Object.maxID;
				}
			},
			_ => throw "error!"
		);

		return obj;
	}

	override function compare(value1: Object, value2: Value, op: ComparisonOp): CompareResult {
		final obj1 = value1;
		final obj2 = value2._match(
			at(o is Object) => o,
			_ => return IsInvalid
		);

		if(obj1.ctx == obj2.ctx) {
			return IsSame;
		} else if(op == CSame) {
			return IsLess;
		}

		//TODO: cycles

		final ctx1 = obj1.ctx;
		final ctx2 = obj2.ctx;
		final sym1 = ctx1.symbols;
		final sym2 = ctx2.symbols;

		final diff = sym1.length.compare(sym2.length);
		if(diff != 0) {
			return cast diff;
		}

		if(sym1.length == 0) {
			return IsSame;
		}

		final value1 = ctx1.values;
		final value2 = ctx2.values;

		//TODO: cycles

		var res = IsSame;
		for(i in 0...sym1.length) {
			final s1 = sym1[i].symbol;
			final s2 = sym2[i].symbol;

			if(!s1.equalsSymbol(s2)) {
				return cast s1.index.compare(s2.index);
			}

			final v1 = value1[i];
			final v2 = value2[i];
			if(
				v1.thisType() == v2.thisType()
				|| (v1 is _AnyWord && v2 is _AnyWord)
				|| (v1 is _Number && v2 is _Number)
			) {
				res = runtime.Actions.compareValue(v1, v2, op);
			} else {
				return cast MathTools.compare(cast v1.TYPE_KIND, cast v2.TYPE_KIND);
			}

			if(res != IsSame) break;
		}

		return res;
	}


	override function copy(value: Object, options: ACopyOptions): Object {
		if(options.types != null) throw "NYI!";
		if(options.part != null) throw "bad";

		final ctx = value.ctx;
		final src = ctx.symbols;
		final size = src.length;

		final newCtx = new Context(src, ctx.values);
		final newObj = new Object(newCtx, value.classID, true);

		if(size == 0) return newObj;

		// process values
		final newValues = newCtx.values;
		
		if(options.deep) {
			for(i in 0...size) {
				final value = newValues[i];
				value._match(
					at((_ is Block || _ is Paren || _ is _Path || _ is _String) => true) => {
						newValues[i] = Copy.call(value, {deep: true});
					},
					at(fn is Function) => {
						newValues[i] = rebind(fn, newCtx, newObj);
					},
					_ => {}
				);
			}
		} else {
			for(i in 0...size) newValues[i]._match(
				at(fn is Function) => {
					newValues[i] = rebind(fn, newCtx, newObj);
				},
				_ => {}
			);
		}

		return newObj;
	}
}