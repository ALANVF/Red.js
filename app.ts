import Red from "./red";

// temporary
Red.evalRed(`
	get: make native! [[
			"Returns the value a word refers to"
			word	[any-word! refinement! path! object!]
			/any  "If word has no value, return UNSET rather than causing an error"
			/case "Use case-sensitive comparison (path only)"
			return: [any-type!]
		]
		get
	]
`);

Red.evalFile("./core/natives.red");
Red.evalFile("./core/actions.red");
Red.evalFile("./core/operators.red");
Red.evalFile("./core/scalars.red");
Red.evalFile("./core/functions.red");
Red.evalFile("./core/interactive.red");



// REPL
import * as rl from "readline";

const io = rl.createInterface({
	input:  process.stdin,
	output: process.stdout,
	prompt: "> "
});

io.prompt();
io.on("line", (input: string) => {
	if(input == "quit") {
		io.close();
	} else {
		try {
			const res = Red.evalRed(input);

			if(!(res instanceof Red.Types.RawUnset)) {
				console.log(res);
			}
		} catch(e) {
			console.log(e);
		}

		console.log();

		io.prompt();
	}
});