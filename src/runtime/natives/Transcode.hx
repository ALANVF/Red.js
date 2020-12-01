package runtime.natives;

import types.Block;
import types.Value;
import types.base.Options;
import types.base._NativeOptions;

class Transcode {
	public static final defaultOptions = Options.defaultFor(NTranscodeOptions);

	public static function call(src: Value, options: NTranscodeOptions) {
		return switch options {
			case  {next: true}
				| {one: true}
				| {prescan: true}
				| {scan: true}
				| {part: Some(_)}
				| {into: Some(_)}
				| {trace: Some(_)}: throw "NYI";
			default: switch src.KIND {
				case KBinary(_): throw "NYI";
				case KString(s): new Block(Tokenizer.parse(s.form()));
				default: throw "error!";
			}
		}
	}
}