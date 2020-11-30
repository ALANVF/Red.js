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
					switch name {
						case "NAT_IF": NIf(runtime.natives.If.call);
						case "NAT_UNLESS": NUnless(runtime.natives.Unless.call);
						case "NAT_EITHER": NEither(runtime.natives.Either.call);
						case "NAT_DO": NDo(runtime.natives.Do.call);
						case "NAT_TRANSCODE": NTranscode(runtime.natives.Transcode.call);
						default: throw "NYI";
					}
				)
			)
		);
	}
}