package runtime.natives;

import types.Block;
import types.Value;
import types.Binary;
import types.base.Options;
import types.base._NativeOptions;

@:build(runtime.NativeBuilder.build())
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
			default: src._match(
				at(_ is Binary) => throw "NYI",
				at(s is types.String) => new Block(Tokenizer.parse(s.form())),
				_ => throw "error!"
			);
		}
	}
}