import types.Value;
import runtime.actions.Form;
import runtime.actions.Mold;

// DO NOT INLINE ANYTHING
@:expose
@:publicFields class RedJS {
	static var printHandler: (String) -> Void;
	static var prinHandler: (String) -> Void;
	static var inputHandler: () -> String;
	static final BUILD: String = Macros.getBuild();
	
	/**
	 * Initialize the runtime
	**/
	static function initRuntime() {
		Runtime.registerDatatypes();

		types.base.Context.GLOBAL.value = new types.Object(types.base.Context.GLOBAL, -1, true);
		runtime.Words.build();
		
		Runtime.registerStdlib();

#if js
		printHandler = if(Util.IS_NODE) {
			s -> js.Syntax.code("process.stdout.write({0} + '\\n')", s);
		} else {
			s -> js.html.Console.log(s);
		}
		prinHandler = if(Util.IS_NODE) {
			s -> js.Syntax.code("process.stdout.write({0})", s);
		} else {
			s -> throw "Can't use `prin` on web!";
		}
		inputHandler = if(Util.IS_NODE) {
			() -> {
				// dumbass language doesn't even have a way to to synchronous input
				final readline: Readline = untyped require('readline');
				final io = readline.createInterface({
					input: untyped process.stdin,
					output: untyped process.stdout,
				});
				var input = {x: null};
				io.question("", _input -> {
					input.x = _input;
				});
				while(input.x == null) {}
				return input.x;
			};
		} else {
			() -> throw "Can't use user input on web";
		}
#end
	}

	/**
	 * Evaluate input code and return a Red value
	**/
	static function evalCode(code: String): Value {
		return runtime.Eval.evalCode(code);
	}
	
	/**
	 * Stringify a Red value
	**/
	static function form(value: Value): String {
		return Form.call(value, Form.defaultOptions).toJs();
	}

	/**
	 * Return a string representation of a Red value
	**/
	static function mold(value: Value): String {
		return Mold.call(value, Mold.defaultOptions).toJs();
	}

	/**
	 * Set output handler for `print` native
	**/
	static function setPrintHandler(handler: (String) -> Void) {
		printHandler = handler;
	}

	/**
	 * Set output handler for `prin` native (excludes newline)
	**/
	static function setPrinHandler(handler: (String) -> Void) {
		prinHandler = handler;
	}

	/**
	 * Set output handler for input handling
	**/
	static function setInputHandler(handler: () -> String) {
		inputHandler = handler;
	}

	/**
	 * Add a JS function hook to the Red global environment
	**/
	static function addJsRoutine(name: String, spec: String, func: types.JsRoutine._Routine) {
		final specCode: types.Block = cast evalCode(spec);
		if(!(specCode is types.Block)) throw "bad";

		final routine = switch runtime.natives.Func.parseSpec(specCode) {
			case {doc: doc, params: params, refines: refines, ret: ret}:
				new types.JsRoutine(specCode, doc, params, refines, ret, func);
			default:
				throw "error: invalid js routine spec";
		};

		types.base.Context.GLOBAL.add(name, routine, false);
	}

	static function makeNone() return types.None.NONE;
	static function makeUnset() return types.Unset.UNSET;
	static function makeInteger(int: Int) return new types.Integer(int);
	static function makeFloat(float: Float) return new types.Float(float);
	static function makeString(str: String) return types.String.fromString(str);
}