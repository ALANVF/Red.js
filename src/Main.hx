// testing things

import Tokenizer;

class Main {
	static function main() {
		/*for(token in Tokenizer.tokenize(Util.readFile("./parse-tests/test1.red"))) trace(Std.string(token));
		for(token in Tokenizer.tokenize(Util.readFile("./parse-tests/test2.red"))) trace(Std.string(token));
		for(token in Tokenizer.tokenize(Util.readFile("./parse-tests/test3.red"))) trace(Std.string(token));*/

		/*final tokens = haxe.Timer.measure(() -> Tokenizer.tokenize(Util.readFile("./parse-tests/test4.red")));
		for(token in tokens) trace(Util.pretty(token));*/
		
		//trace(Do.call(types.String.fromRed("123 [456 #abc] \"banana\""), Do.defaultOptions));

		@:privateAccess Runtime.registerDatatypes(types.base.Context.GLOBAL);

		types.base.Context.GLOBAL.add(
			"make",
			new types.Action(
				None,
				[
					{name: "type", quoting: QVal},
					{name: "spec", quoting: QVal}
				],
				[],
				None,
				AMake(runtime.actions.Make.call)
			)
		);

		types.base.Context.GLOBAL.add(
			"either",/*
			types.Unset.UNSET
		).setValue(*/
			new types.Native(
				None,
				[
					{name: "cond", quoting: types.base.IFunction.QuotingKind.QVal},
					{name: "true-blk", quoting: types.base.IFunction.QuotingKind.QVal},
					{name: "else-blk", quoting: types.base.IFunction.QuotingKind.QVal}
				],
				[],
				None,
				NEither(runtime.natives.Either.call)
			)
		);

		types.base.Context.GLOBAL.add(
			"loop",
			new types.Native(
				None,
				[
					{name: "count", quoting: types.base.IFunction.QuotingKind.QVal},
					{name: "body", quoting: types.base.IFunction.QuotingKind.QVal},
				],
				[],
				None,
				NLoop(runtime.natives.Loop.call)
			)
		);
		
		runtime.Eval.evalCode("do: make native! [[
				value [any-type!]
				/expand
				/args
					arg
				/next
					position [word!]
			]
			#get-definition NAT_DO
		]");

		js.Syntax.code("
var readline = require('readline');
var io = readline.createInterface({
	input: process.stdin,
	output: process.stdout,
	prompt: '> '
});
io.prompt(true);
io.on('line', function(input) {
	if(input === 'quit') {
		io.close();
		return;
	} else {
		({0})(input);
	}
	console.log();
	io.prompt(true);
});",
			(input: String) -> {
				try {
					final res = runtime.Eval.evalCode(input);
					js.Syntax.code("console.log({0})", res);
				} catch(e) {
					js.Syntax.code("console.log({0})", e.details());
				}
			}
		);
	}
}