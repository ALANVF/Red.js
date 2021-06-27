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

		runtime.Eval.evalCode("
			either: make native! [[
					cond     [logic!]
					true-blk [block!]
					else-blk [block!]
				]
				#get-definition NAT_EITHER
			]

			loop: make native! [[
					count [integer!]
					body  [block!]
				]
				#get-definition NAT_LOOP
			]
			
			
			foreach: make native! [[
					'word  [word! block!]
					series [series! map!]
					body   [block!]
				]
				#get-definition NAT_FOREACH
			]
			
			forall: make native! [[
					'word [word!]
					body  [block!]
				]
				#get-definition NAT_FORALL
			]
			
			remove-each: make native! [[
					'word [word! block!]
					data [series!]
					body [block!]
				]
				#get-definition NAT_REMOVE_EACH
			]
			
			do: make native! [[
					value [any-type!]
					/expand
					/args
						arg
					/next
						position [word!]
				]
				#get-definition NAT_DO
			]
			
			reduce: make native! [[
					value [any-type!]
					/into
						out [any-block!]
				]
				#get-definition NAT_REDUCE
			]

			print: make native! [[
					value [any-type!]
				]
				#get-definition NAT_PRINT
			]
			
			equal?: make native! [[
					value1 [any-type!]
					value2 [any-type!]
				]
				#get-definition NAT_EQUAL?
			]
			
			not-equal?: make native! [[
					value1 [any-type!]
					value2 [any-type!]
				]
				#get-definition NAT_NOT_EQUAL?
			]
			
			strict-equal?: make native! [[
					value1 [any-type!]
					value2 [any-type!]
				]
				#get-definition NAT_STRICT_EQUAL?
			]
			
			lesser?: make native! [[
					value1 [any-type!]
					value2 [any-type!]
				]
				#get-definition NAT_LESSER?
			]
			
			greater?: make native! [[
					value1 [any-type!]
					value2 [any-type!]
				]
				#get-definition NAT_GREATER?
			]
			
			lesser-or-equal?: make native! [[
					value1 [any-type!]
					value2 [any-type!]
				]
				#get-definition NAT_LESSER_OR_EQUAL?
			]
			
			greater-or-equal?: make native! [[
					value1 [any-type!]
					value2 [any-type!]
				]
				#get-definition NAT_GREATER_OR_EQUAL?
			]
			
			same?: make native! [[
					value1 [any-type!]
					value2 [any-type!]
				]
				#get-definition NAT_SAME?
			]
		");

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