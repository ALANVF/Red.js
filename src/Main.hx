import js.Browser.console;

class Main {
	static inline final DEBUG = false;

	static function main() {
		RedJS.initRuntime();

		(untyped setTimeout)(() -> {
			if(!DEBUG) console.clear();
			console.log('Build ${RedJS.BUILD}\n');

			final readline: Readline = untyped require('readline');
			final stdout: { function write(s: String): Void; } = untyped process.stdout;
			final io = readline.createInterface({
				input: untyped process.stdin,
				output: stdout,
			//	prompt: ">> " // this keeps clearing output from `prin` and idk why
			});
			//io.prompt(true);
			stdout.write(">> ");
			io.on("line", (input: String) -> {
				if(DEBUG && input == "quit") {
					io.close();
					return;
				} else {
					try {
						final res = RedJS.evalCode(input);
						if(res != types.Unset.UNSET) {
							console.log("==", DEBUG ? res : RedJS.mold(res));
						}
					} catch(e) {
						console.log(e.details());
						console.log();
					}
			//		io.prompt(true);
					stdout.write(">> ");
				}
			});
		}, 1);
	}
}