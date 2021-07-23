package types;

import types.base.ISeriesOf;
import types.base._SeriesOf;
import types.base.IValue;
import haxe.ds.Option;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;

using util.ContextTools;
using haxe.macro.ComplexTypeTools;
using haxe.macro.TypeTools;

class Helpers {
	public static macro function as<T: IValue>(value: ExprOf<IValue>, type: ExprOf<Class<T>>): ExprOf<T> {
		final tpath = haxe.macro.ExprTools.toString(type);
		final path = tpath.split(".");
		final nparams = switch Context.getType(tpath) {
			case TInst(_, params): params.length;
			case _: throw "todo!";
		};
		final ttype = TPath({
			pack: path.slice(0, path.length - 2),
			name: path[path.length - 1],
			params: [for(_ in 0...nparams) TPType(macro:Dynamic)]
		});
		return macro cast($value, $ttype);
	}
	
	public static inline function asISeries(value: IValue): ISeriesOf<Value> {
		return (untyped value.as(ISeriesOf) : ISeriesOf<Value>);
	}
	
	public static inline function asSeries(value: IValue): _SeriesOf<Value> {
		return (untyped value.as(_SeriesOf) : _SeriesOf<Value>);
	}

	public static macro function is<T: IValue>(value: ExprOf<IValue>, type: ExprOf<Class<T>>): ExprOf<Option<T>> {
		final path = haxe.macro.ExprTools.toString(type).split(".");
		final ttype = switch Context.getType(haxe.macro.ExprTools.toString(type)) {
			case TInst(_, []):
				TPath({
					pack: path.slice(0, path.length - 2),
					name: path[path.length - 1]
				});
			
			case TInst(_, params):
				TPath({
					pack: path.slice(0, path.length - 2),
					name: path[path.length - 1],
					params: [for(_ in 0...params.length) TPType(TPath({pack: [], name: "Dynamic"}))]
				});
			
			case _: throw "error!";
		};
		final tmp = Context.newTempVar();
		return macro {
			final $tmp = $value;
			if(Std.isOfType($i{tmp}, ${type})) {
				Some(cast($value, $ttype));
			} else {
				None;
			}
		}
	}
	
	public static inline function isISeries(value: IValue): Option<ISeriesOf<Value>> {
		return if(value is ISeriesOf) {
			Some((untyped value : ISeriesOf<Value>));
		} else {
			None;
		}
	}
	
	public static inline function isSeries(value: IValue): Option<_SeriesOf<Value>> {
		return if(value is _SeriesOf) {
			Some((untyped value : _SeriesOf<Value>));
		} else {
			None;
		}
	}
}