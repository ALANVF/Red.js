package runtime.actions.datatypes;

import types.Block;
import types.Native;
import types.Value;
import types.Issue;
import types.Word;
import haxe.ds.Option;
import Util.match;
import Util.extract;

using util.OptionTools;
using util.EnumValueTools;
using types.Helpers;
using Lambda;

class NativeActions extends ValueActions {
	public static var MAPPINGS: Map<String, NativeFn>;

	static function __init__() {
		MAPPINGS = [];
	}

	override public function make(_, spec: Value) {
		extract(spec.as(Block).array(), [
			_.is(Block) => Some(s),
			_.is(Issue) => Some(_.name => "get-definition"),
			_.is(Word) => Some(_.name => name)],
			match(runtime.natives.Func.parseSpec(s), {doc: doc, args: args, refines: refines, ret: ret},
				return new Native(
					doc,
					args,
					refines,
					ret,
					/*switch name {
						case "NAT_IF": NIf(runtime.natives.If.call);
						case "NAT_UNLESS": NUnless(runtime.natives.Unless.call);
						case "NAT_EITHER": NEither(runtime.natives.Either.call);
						case "NAT_ANY": NAny(runtime.natives.Any.call);
						case "NAT_ALL": NAll(runtime.natives.All.call);
						case "NAT_WHILE": NWhile(runtime.natives.While.call);
						case "NAT_UNTIL": NUntil(runtime.natives.Until.call);
						case "NAT_DO": NDo(runtime.natives.Do.call);
						case "NAT_GET": NGet(runtime.natives.Get.call);
						case "NAT_SET": NSet(runtime.natives.Set.call);
						case "NAT_TRANSCODE": NTranscode(runtime.natives.Transcode.call);
						default: throw "NYI";
					}*/
					if(MAPPINGS.exists(name)) {
						MAPPINGS[name];
					} else {
						throw "NYI";
					}
				)
			)
		);
	}
}