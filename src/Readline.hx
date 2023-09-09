extern class Interface {
	extern function prompt(?preserveCursor: Bool): Void;
	extern function close(): Void;
	extern function on(event: String, listener: (input: String) -> Void): Interface;
}

extern class Readline {
	extern function createInterface(options: {input: Any, output: Any, ?prompt: String}): Interface;
}