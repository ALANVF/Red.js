package runtime.natives;

import types.Refinement;
import types.base.Symbol;
import types.Block;
import types.String;
import types.SetWord;
import types.base.IFunction;
import haxe.ds.Option;
import Util.match;

using util.EnumValueTools;
using types.Helpers;

class Func {
	public static function parseSpec(spec: Block) {
		final res = {
			doc: None,
			args: [],
			refines: [],
			ret: None
		};

		spec = spec.copy();

		inline function getArgs(args: _Args) {
			while(true) {
				match(spec.pick(0), Some(_.KIND => KWord((_ : Symbol) => w) | KGetWord(w) | KLitWord(w)), {
					spec.index++;

					args.push({
						name: w.name,
						quoting: switch w.TYPE_KIND {
							case DWord:    QVal;
							case DGetWord: QGet;
							default:       QLit;
						},
						spec: spec.pick(0).extractMap(_.is(Block) => Some(b), {
							spec.index++;
							b.copy();
						}),
						doc: spec.pick(0).extractMap(_.is(String) => Some(s), {
							spec.index++;
							s.form();
						})
					});
				}, break);
			}
		}

		inline function getRet() {
			spec.pick(0).extractIter(_.is(SetWord) => Some(_.equalsString("return") => true), {
				spec.index++;
				spec.pick(0).extract(Some(_.is(Block) => Some(b)), {
					spec.index++;
					res.ret = Some(b.copy());
				}, throw "Missing return spec!");
			});
		}
		
		spec.pick(0).extractIter(_.is(String) => Some(s), {
			spec.index++;
			res.doc = Some(s.form());
		});

		getArgs(res.args);

		getRet();

		while(true) {
			match(spec.pick(0), Some(_.is(Refinement) => Some(r)), {
				spec.index++;
				
				final refine: _Refine = {
					name: r.name,
					doc: spec.pick(0).extractMap(_.is(String) => Some(s), {
						spec.index++;
						s.form();
					})
				};

				getArgs(refine.args);

				res.refines.push(refine);
			}, break);
		}
		
		if(res.ret == None) {
			getRet();
		}

		if(spec.length != 0) {
			throw "Invalid function spec!";
		}

		return res;
	}
}