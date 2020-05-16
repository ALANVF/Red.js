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

Red.evalFile("./core/scalars.red");
Red.evalFile("./core/natives.red");
Red.evalFile("./core/actions.red");
Red.evalFile("./core/operators.red");

/*
import {performance} from "perf_hooks";

const tb = performance.now();
Red.evalRed(`
hanoi: func [
	{Begin moving the golden disks from one pole to the next.
	 Note: when last disk moved, the world will end.}
	disks [integer!] "Number of discs on starting pole."
	/poles "Name poles."
		from
		to_
		via
][
	if disks = 0 [return]
	if not poles [from: 'left  to_: 'middle  via: 'right]
	
	hanoi/poles disks - 1 from via to_
	print form reduce [from "->" to_]
	hanoi/poles disks - 1 via to_ from
]

hanoi 4
`);
const te = performance.now();

console.log("Time taken: ", te - tb, "ms");*/



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