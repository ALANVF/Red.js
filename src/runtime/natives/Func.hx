package runtime.natives;

import types.Refinement;
import types.base.Symbol;
import types.Block;
import types.Word;
import types.LitWord;
import types.GetWord;
import types.SetWord;
import types.Function;
import types.base.IFunction;

// TODO: improve this
@:build(runtime.NativeBuilder.build())
class Func {
	public static function parseSpec(spec: Block) {
		final res = {
			doc: null,
			params: [],
			refines: [],
			ret: null
		};

		spec = spec.copy();

		inline function getParams(params: _Params) {
			while(true) {
				spec.pick(0)._match(
					at(w is Word | w is GetWord | w is LitWord) => {
						spec.index++;

						params.push({
							name: w.symbol.name,
							quoting: switch w.TYPE_KIND {
								case DWord:    QVal;
								case DGetWord: QGet;
								default:       QLit;
							},
							spec: spec.pick(0)._match(
								at(b is Block) => {
									spec.index++;
									b.copy();
								},
								_ => null
							),
							doc: spec.pick(0)._match(
								at(s is types.String) => {
									spec.index++;
									s.form();
								},
								_ => null
							)
						});
					},
					_ => break
				);
			}
		}

		inline function getRet() {
			spec.pick(0)._match(
				at((_.symbol.equalsString("return") => true) is SetWord) => {
					spec.index++;
					spec.pick(0)._match(
						at(b is Block) => {
							spec.index++;
							res.ret = b.copy();
						},
						_ => throw "Missing return spec!"
					);
				},
				_ => {}
			);
		}
		
		spec.pick(0)._match(
			at(s is types.String) => {
				spec.index++;
				res.doc = s.form();
			},
			_ => {}
		);

		getParams(res.params);

		getRet();

		while(true) {
			spec.pick(0)._match(
				at(r is Refinement) => {
					spec.index++;
					
					final refine: _Refine = {
						name: r.symbol.name,
						doc: spec.pick(0)._match(
							at(s is types.String) => {
								spec.index++;
								s.form();
							},
							_ => null
						)
					};

					getParams(refine.params);

					res.refines.push(refine);
				},
				_ => break
			);
		}
		
		if(res.ret == null) {
			getRet();
		}

		if(spec.length != 0) {
			throw "Invalid function spec!";
		}

		return res;
	}

	public static function call(spec: Block, body: Block): Function {
		parseSpec(spec)._match(
			at({doc: doc, params: params, refines: refines, ret: ret}) => {
				return new Function(null, spec, doc, params, refines, ret, body.copy());
			}
		);
	}
}