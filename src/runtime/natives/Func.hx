package runtime.natives;

import types.Refinement;
import types.base.Symbol;
import types.Block;
import types.Word;
import types.LitWord;
import types.GetWord;
import types.SetWord;
import types.base.IFunction;
import haxe.ds.Option;

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
				spec.pick(0)._match(
					at(Some(w is Word | w is GetWord | w is LitWord)) => {
						spec.index++;

						args.push({
							name: w.name,
							quoting: switch w.TYPE_KIND {
								case DWord:    QVal;
								case DGetWord: QGet;
								default:       QLit;
							},
							spec: spec.pick(0)._match(
								at(Some(b is Block)) => {
									spec.index++;
									Some(b.copy());
								},
								_ => None
							),
							doc: spec.pick(0)._match(
								at(s is types.String) => {
									spec.index++;
									Some(s.form());
								},
								_ => None
							)
						});
					},
					_ => break
				);
			}
		}

		inline function getRet() {
			spec.pick(0)._match(
				at(Some((_.equalsString("return") => true) is SetWord)) => {
					spec.index++;
					spec.pick(0)._match(
						at(Some(b is Block)) => {
							spec.index++;
							res.ret = Some(b.copy());
						},
						_ => throw "Missing return spec!"
					);
				},
				_ => {}
			);
		}
		
		spec.pick(0)._match(
			at(Some(s is types.String)) => {
				spec.index++;
				res.doc = Some(s.form());
			},
			_ => {}
		);

		getArgs(res.args);

		getRet();

		while(true) {
			spec.pick(0)._match(
				at(Some(r is Refinement)) => {
					spec.index++;
					
					final refine: _Refine = {
						name: r.name,
						doc: spec.pick(0)._match(
							at(Some(s is types.String)) => {
								spec.index++;
								Some(s.form());
							},
							_ => None
						)
					};

					getArgs(refine.args);

					res.refines.push(refine);
				},
				_ => break
			);
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