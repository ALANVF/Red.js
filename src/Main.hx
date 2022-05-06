class Main {
	static function main() {
		/*for(token in Tokenizer.tokenize(Util.readFile("./parse-tests/test1.red"))) trace(Std.string(token));
		for(token in Tokenizer.tokenize(Util.readFile("./parse-tests/test2.red"))) trace(Std.string(token));
		for(token in Tokenizer.tokenize(Util.readFile("./parse-tests/test3.red"))) trace(Std.string(token));*/

		/*final tokens = haxe.Timer.measure(() -> Tokenizer.tokenize(Util.readFile("./parse-tests/test4.red")));
		for(token in tokens) trace(Util.pretty(token));*/
		
		//trace(Do.call(types.String.fromRed("123 [456 #abc] \"banana\""), Do.defaultOptions));
		
		@:privateAccess Runtime.registerDatatypes();

		types.base.Context.GLOBAL.add(
			"make",
			new types.Action(
				null,
				[
					{name: "type", quoting: QVal},
					{name: "spec", quoting: QVal}
				],
				[],
				null,
				runtime.actions.datatypes.ActionActions.MAPPINGS["ACT_MAKE"]
			)
		);
		
		runtime.Eval.evalCode("
			absolute: make action! [[
					value	[number! money! char! pair! time!]
					return: [number! money! char! pair! time!]
				]
				#get-definition ACT_ABSOLUTE
			]
			
			add: make action! [[
					value1	[scalar! vector!]
					value2	[scalar! vector!]
					return: [scalar! vector!]
				]
				#get-definition ACT_ADD
			]
		");

		runtime.Eval.evalCode("
			if: make native! [[
					cond  	 [any-type!]
					then-blk [block!]
				]
				#get-definition NAT_IF
			]
			
			unless: make native! [[
					cond  	 [any-type!]
					then-blk [block!]
				]
				#get-definition NAT_UNLESS
			]

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

			repeat: make native! [[
					'word [word!]
					value [integer! float!]
					body  [block!]
				]
				#get-definition NAT_REPEAT
			]

			forever: make native! [[
					body   [block!]
				]
				#get-definition NAT_FOREVER
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

			func: make native! [[
					spec [block!]
					body [block!]
				]
				#get-definition NAT_FUNC
			]

			does: make native! [[
					body [block!]
				]
				#get-definition NAT_DOES
			]
			
			has: make native! [[
					vars [block!]
					body [block!]
				]
				#get-definition NAT_HAS
			]

			switch: make native! [[
					value [any-type!]
					cases [block!]
					/default
						case [block!]
				]
				#get-definition NAT_SWITCH
			]
			
			case: make native! [[
					cases [block!]
					/all
				]
				#get-definition NAT_CASE
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

			compose: make native! [[
					value [block!]
					/deep
					/only
					/into
						out [any-block!]
				]
				#get-definition NAT_COMPOSE
			]

			get: make native! [[
					word	[any-word! any-path! object!]
					/any
					/case
					return: [any-type!]
				] 
				#get-definition NAT_GET
			]
			
			set: make native! [[
					word	[any-word! block! object! any-path!]
					value	[any-type!]
					/any
					/case
					/only
					/some
					return: [any-type!]
				]
				#get-definition NAT_SET
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

			not: make native! [[
					value [any-type!]
				]
				#get-definition NAT_NOT
			]
			
			type?: make native! [[
					value [any-type!]
					/word
				]
				#get-definition NAT_TYPE?
			]

			;stats

			bind: make native! [[
					word 	[block! any-word!]
					context [any-word! any-object! function!]
					/copy
					return: [block! any-word!]
				]
				#get-definition NAT_BIND
			]
			
			in: make native! [[
					object [any-object!]
					word   [any-word!]
				]
				#get-definition NAT_IN
			]

			; ...

			union: make native! [[
					set1 [block! hash! string! bitset! typeset!]
					set2 [block! hash! string! bitset! typeset!]
					/case
					/skip
						size [integer!]
					return: [block! hash! string! bitset! typeset!]
				]
				#get-definition NAT_UNION
			]

			; ...
			
			min: make native! [[value1 value2] #get-definition NAT_MIN]
			max: make native! [[value1 value2] #get-definition NAT_MAX]

			shift: make native! [[
					data [integer!]
					bits [integer!]
					/left
					/logical
				]
				#get-definition NAT_SHIFT
			]

			; ...

			zero?: make native! [[
					value	[number! money! pair! time! char! tuple!]
					return: [logic!]
				]
				#get-definition NAT_ZERO?
			]
			
			; ...

			construct: make native! [[
					block [block!]
					/with
						object [object!]
					/only
				]
				#get-definition NAT_CONSTRUCT
			]

			value?: make native! [[
					value
					return: [logic!]
				]
				#get-definition NAT_VALUE?
			]

			try: make native! [[
					block	[block!]
					/all
					/keep
				]
				#get-definition NAT_TRY
			]

			uppercase: make native! [[
					string		[any-string! char!]
					/part
						limit	[number! any-string!]
					return: 	[any-string! char!]
				]
				#get-definition NAT_UPPERCASE
			]
			
			lowercase: make native! [[
					string		[any-string! char!]
					/part
						limit	[number! any-string!]
					return:		[any-string! char!]
				]
				#get-definition NAT_LOWERCASE
			]

			as-pair: make native! [[
					x [integer! float!]
					y [integer! float!]
				]
				#get-definition NAT_AS_PAIR
			]

			; ...

			break: make native! [[
					/return
						value [any-type!]
				]
				#get-definition NAT_BREAK
			]
			
			continue: make native! [[
				]
				#get-definition NAT_CONTINUE
			]
			
			exit: make native! [[
				]
				#get-definition NAT_EXIT
			]
			
			return: make native! [[
					value [any-type!]
				]
				#get-definition NAT_RETURN
			]

			throw: make native! [[
					value [any-type!]
					/name
						word [word!]
				]
				#get-definition NAT_THROW
			]

			catch: make native! [[
					block [block!]
					/name
						word [word! block!]
				]
				#get-definition NAT_CATCH
			]

			extend: make native! [[
					obj  [object! map!]
					spec [block! hash! map!]
					/case
				]
				#get-definition NAT_EXTEND
			]

			unset: make native! [[
					word [word! block!]
				]
				#get-definition NAT_UNSET
			]

			new-line: make native! [[
					position [any-list!]
					value	 [logic!]
					/all
					/skip
						size [integer!]
					return:  [any-list!]
				]
				#get-definition NAT_NEW_LINE
			]

			new-line?: make native! [[
					position [any-list!]
					return:  [logic!]
				]
				#get-definition NAT_NEW_LINE?
			]

			+: make op! :add
			=: make op! :equal?
			<>: make op! :not-equal?
			==: make op! :strict-equal?
			=?: make op! :same?
			<: make op! :lesser?
			>: make op! :greater?
			<=: make op! :lesser-or-equal?
			>=: make op! :greater-or-equal?
		");

		runtime.Eval.evalCode("
			internal!:		make typeset! [unset!]
			external!:		make typeset! [] ;#if find config/modules 'view [event!]
			number!:		make typeset! [integer! float! percent!]
			scalar!:		union number! make typeset! [money! char! pair! tuple! time! date!]
			any-word!:		make typeset! [word! set-word! get-word! lit-word!] ;-- any bindable word
			all-word!:		union any-word! make typeset! [refinement! issue!]	;-- all types of word nature
			any-list!:		make typeset! [block! paren! hash!]
			any-path!:		make typeset! [path! set-path! get-path! lit-path!]
			any-block!:		union any-path! any-list!
			any-function!:	make typeset! [native! action! op! function!] ;routine!
			any-object!:	make typeset! [object! error!] ;port!
			any-string!:	make typeset! [string! file! url! tag! email! ref!]
			series!:		union make typeset! [binary!] union any-block! any-string! ;image! vector!
			immediate!:		union scalar! union all-word! make typeset! [none! logic! datatype! typeset! date!] ;handle!
			default!:		union series! union immediate! union any-object! union external! union any-function! make typeset! [map! bitset!]
			any-type!:		union default! internal!
		");
		
		js.Syntax.code("
const readline = require('readline');
const io = readline.createInterface({
	input: process.stdin,
	output: process.stdout,
	prompt: '> '
});
io.prompt(true);
io.on('line', (input) => {
	if(input === 'quit') {
		io.close();
		return;
	} else {
		({0})(input);
		console.log();
		io.prompt(true);
	}
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