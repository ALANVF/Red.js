import js.Browser.console;

class Main {
	static inline final DEBUG = false;

	static function main() {
		@:privateAccess Runtime.registerDatatypes();

		types.base.Context.GLOBAL.value = new types.Object(types.base.Context.GLOBAL, -1, true);

		runtime.Words.build();

		types.base.Context.GLOBAL.add(
			"make",
			new types.Action(
				null,
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
			make: make action! [[
					type	 [any-type!]
					spec	 [any-type!]
					return:  [any-type!]
				]
				#get-definition ACT_MAKE
			]

			reflect: make action! [[
					value	[any-type!]
					field 	[word!]
				]
				#get-definition ACT_REFLECT
			]
			
			to: make action! [[
					type	[any-type!]
					spec	[any-type!]
				]
				#get-definition ACT_TO
			]

			form: make action! [[
					value	  [any-type!]
					/part
						limit [integer!]
					return:	  [string!]
				]
				#get-definition ACT_FORM
			]
			
			mold: make action! [[
					value	  [any-type!]
					/only
					/all
					/flat
					/part
						limit [integer!]
					return:	  [string!]
				]
				#get-definition ACT_MOLD
			]
			
			absolute: make action! [[
					value	[number! money! char! pair! time!]
					return: [number! money! char! pair! time!]
				]
				#get-definition ACT_ABSOLUTE
			]

			negate: make action! [[
					number 	 [number! money! bitset! pair! time!]
					return:  [number! money! bitset! pair! time!]
				]
				#get-definition ACT_NEGATE
			]
			
			add: make action! [[
					value1	[scalar! vector!]
					value2	[scalar! vector!]
					return: [scalar! vector!]
				]
				#get-definition ACT_ADD
			]

			subtract: make action! [[
					value1	 [scalar! vector!]
					value2	 [scalar! vector!]
					return:  [scalar! vector!]
				]
				#get-definition ACT_SUBTRACT
			]

			multiply: make action! [[
					value1	 [number! money! char! pair! tuple! vector! time!]
					value2	 [number! money! char! pair! tuple! vector! time!]
					return:  [number! money! char! pair! tuple! vector! time!]
				]
				#get-definition ACT_MULTIPLY
			]

			divide: make action! [[
					value1	 [number! money! char! pair! tuple! vector! time!]
					value2	 [number! money! char! pair! tuple! vector! time!]
					return:  [number! money! char! pair! tuple! vector! time!]
				]
				#get-definition ACT_DIVIDE
			]

			power: make action! [[
					number	 [number!]
					exponent [integer! float!]
					return:	 [number!]
				]
				#get-definition ACT_POWER
			]

			remainder: make action! [[
					value1 	 [number! money! char! pair! tuple! vector! time!]
					value2 	 [number! money! char! pair! tuple! vector! time!]
					return:  [number! money! char! pair! tuple! vector! time!]
				]
				#get-definition ACT_REMAINDER
			]

			round: make action! [[
					n		[number! money! time! pair!]
					/to
					scale	[number! money! time! pair!]
					/even
					/down
					/half-down
					/floor
					/ceiling
					/half-ceiling
				]
				#get-definition ACT_ROUND
			]

			even?: make action! [[
					number 	 [number! money! char! time!]
					return:  [logic!]
				]
				#get-definition ACT_EVEN?
			]
			
			odd?: make action! [[
					number 	 [number! money! char! time!]
					return:  [logic!]
				]
				#get-definition ACT_ODD?
			]
		

			and~: make action! [[
					value1	[logic! integer! char! bitset! binary! typeset! pair! tuple! vector!]
					value2	[logic! integer! char! bitset! binary! typeset! pair! tuple! vector!]
					return:	[logic! integer! char! bitset! binary! typeset! pair! tuple! vector!]
				]
				#get-definition ACT_AND~
			]

			complement: make action! [[
					value	[logic! integer! tuple! bitset! typeset! binary!]
					return: [logic! integer! tuple! bitset! typeset! binary!]
				]
				#get-definition ACT_COMPLEMENT
			]

			or~: make action! [[
					value1	[logic! integer! char! bitset! binary! typeset! pair! tuple! vector!]
					value2	[logic! integer! char! bitset! binary! typeset! pair! tuple! vector!]
					return:	[logic! integer! char! bitset! binary! typeset! pair! tuple! vector!]
				]
				#get-definition ACT_OR~
			]
			
			xor~: make action! [[
					value1	[logic! integer! char! bitset! binary! typeset! pair! tuple! vector!]
					value2	[logic! integer! char! bitset! binary! typeset! pair! tuple! vector!]
					return:	[logic! integer! char! bitset! binary! typeset! pair! tuple! vector!]
				]
				#get-definition ACT_XOR~
			]

			append: make action! [[
					series	   [series! bitset! port!]
					value	   [any-type!]
					/part
						length [number! series!]
					/only
					/dup
						count  [integer!]
					return:    [series! port! bitset!]
				]
				#get-definition ACT_APPEND
			]

			at: make action! [[
					series	 [series! port!]
					index 	 [integer! pair!]
					return:  [series! port!]
				]
				#get-definition ACT_AT
			]
			
			back: make action! [[
					series	 [series! port!]
					return:  [series! port!]
				]
				#get-definition ACT_BACK
			]

			clear: make action! [[
					series	 [series! port! bitset! map! none!]
					return:  [series! port! bitset! map! none!]
				]
				#get-definition ACT_CLEAR
			]

			copy: make action! [[
					value	 [series! any-object! bitset! map!]
					/part
						length [number! series! pair!]
					/deep
					/types
						kind [datatype!]
					return:  [series! any-object! bitset! map!]
				]
				#get-definition ACT_COPY
			]

			head: make action! [[
					series	 [series! port!]
					return:  [series! port!]
				]
				#get-definition ACT_HEAD
			]
			
			head?: make action! [[
					series	 [series! port!]
					return:  [logic!]
				]
				#get-definition ACT_HEAD?
			]
			
			index?: make action! [[
					series	 [series! port! any-word!]
					return:  [integer!]
				]
				#get-definition ACT_INDEX?
			]

			insert: make action! [[
					series	   [series! port! bitset!]
					value	   [any-type!]
					/part
						length [number! series!]
					/only
					/dup
						count  [integer!]
					return:    [series! port! bitset!]
				]
				#get-definition ACT_INSERT
			]

			length?: make action! [[
					series	 [series! port! bitset! map! tuple! none!]
					return:  [integer! none!]
				]
				#get-definition ACT_LENGTH?
			]

			next: make action! [[
					series	 [series! port!]
					return:  [series! port!]
				]
				#get-definition ACT_NEXT
			]

			skip: make action! [[
					series	 [series! port!]
					offset 	 [integer! pair!]
					return:  [series! port!]
				]
				#get-definition ACT_SKIP
			]

			pick: make action! [[
					series	 [series! bitset! pair! tuple! money! date! time!]
					index 	 [scalar! any-string! any-word! block! logic! time!]
					return:  [any-type!]
				]
				#get-definition ACT_PICK
			]

			poke: make action! [[
					series	 [series! port! bitset!]
					index 	 [scalar! any-string! any-word! block! logic!]
					value 	 [any-type!]
					return:  [series! port! bitset!]
				]
				#get-definition ACT_POKE
			]

			reverse: make action! [[
					series	 [series! port! pair! tuple!]
					/part
						length [number! series!]
					/skip
						size [integer!]
					return:  [series! port! pair! tuple!]
				]
				#get-definition ACT_REVERSE
			]

			swap: make action! [[
					series1  [series! port!]
					series2  [series! port!]
					return:  [series! port!]
				]
				#get-definition ACT_SWAP
			]
			
			tail: make action! [[
					series	 [series! port!]
					return:  [series! port!]
				]
				#get-definition ACT_TAIL
			]
			
			tail?: make action! [[
					series	 [series! port!]
					return:  [logic!]
				]
				#get-definition ACT_TAIL?
			]

			take: make action! [[
					series	 [series! port! none!]
					/part
						length [number! series!]
					/deep
					/last
				]
				#get-definition ACT_TAKE
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

			any: make native! [[
					conds [block!]
				]
				#get-definition NAT_ANY
			]
			
			all: make native! [[
					conds [block!]
				]
				#get-definition NAT_ALL
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

			prin: make native! [[
					value [any-type!]
				]
				#get-definition NAT_PRIN
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

			unique: make native! [[
					set [block! hash! string!]
					/case
					/skip
						size [integer!]
					return: [block! hash! string!]
				]
				#get-definition NAT_UNIQUE
			]
			
			intersect: make native! [[
					set1 [block! hash! string! bitset! typeset!]
					set2 [block! hash! string! bitset! typeset!]
					/case
					/skip
						size [integer!]
					return: [block! hash! string! bitset! typeset!]
				]
				#get-definition NAT_INTERSECT
			]
			
			difference: make native! [[
					set1 [block! hash! string! bitset! typeset! date!]
					set2 [block! hash! string! bitset! typeset! date!]
					/case
					/skip
						size [integer!]
					return: [block! hash! string! bitset! typeset! time!]
				]
				#get-definition NAT_DIFFERENCE
			]
			
			exclude: make native! [[
					set1 [block! hash! string! bitset! typeset!]
					set2 [block! hash! string! bitset! typeset!]
					/case
					/skip
						size [integer!]
					return: [block! hash! string! bitset! typeset!]
				]
				#get-definition NAT_EXCLUDE
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

			context?: make native! [[
					word	[any-word!]
					return: [object! function! none!]
				]
				#get-definition NAT_CONTEXT?
			]

			now: make native! [[
					/year
					/month
					/day
					/time
					/zone
					/date
					/weekday
					/yearday
					/precise
					/utc
					return: [date! time! integer!]
				]
				#get-definition NAT_NOW
			]

			sign?: make native! [[
					number [number! money! time!]
					return: [integer!]
				]
				#get-definition NAT_SIGN?
			]

			as: make native! [[
					type	[datatype! block! paren! any-path! any-string!]
					spec	[block! paren! any-path! any-string!]
				]
				#get-definition NAT_AS
			]

			apply: make native! [[
					func	[word! path! any-function!]
					args	[block!]
					/all
					/safer
				]
				#get-definition NAT_APPLY
			]

			+: make op! :add
			-: make op! :subtract
			*: make op! :multiply
			/: make op! :divide
			%: make op! :remainder
			**: make op! :power
			and: make op! :and~
			or: make op! :or~
			xor: make op! :xor~
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
			any-point!:     make typeset! [point2D! point3D!]
			scalar!:		union number! union any-point! make typeset! [money! char! pair! tuple! time! date!]
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

			Red: none: #[none]
			true: yes: on: #[true]
			false: no: off: #[false]

			newline: #\"^/\"
			tab: #\"^-\"
		");

		(untyped setTimeout)(() -> {
			if(!DEBUG) console.clear();
			console.log('Build ${Macros.getBuild()}\n');

			final readline: Readline = js.Syntax.code("require('readline')");
			final io = readline.createInterface({
				input: js.Syntax.code("process.stdin"),
				output: js.Syntax.code("process.stdout"),
				prompt: ">> "
			});
			io.prompt(true);
			io.on("line", (input: String) -> {
				if(DEBUG && input == "quit") {
					io.close();
					return;
				} else {
					try {
						final res = runtime.Eval.evalCode(input);
						if(res != types.Unset.UNSET) {
							console.log("==", DEBUG ? res : runtime.actions.Mold.call(res, runtime.actions.Mold.defaultOptions).toJs());
						}
					} catch(e) {
						console.log(e.details());
						console.log();
					}
					io.prompt(true);
				}
			});
		}, 1);
	}
}