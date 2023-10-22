package tokenizer;

import js.lib.RegExp;

typedef Loc = {line: Int, column: Int};

class Reader {
	public final stream: String;
	public var pos: Int;

	public function new(input: String) {
		stream = input;
		pos = 0;
	}

	public function eof() {
		return this.pos >= this.stream.length;
	}

	public function peek(length: Int = 1): Null<String> {
		return if(this.eof() || this.pos + length > this.stream.length) {
			null;
		} else {
			this.stream.substr(this.pos, length);
		}
	}

	public function peekAt(pos: Int, length: Int = 1): Null<String> {
		return if(this.eof() || this.pos + pos + length > this.stream.length) {
			null;
		} else {
			this.stream.substr(this.pos + pos, length);
		}
	}

	public function peekCharAt(pos: Int = 0): Null<Int> {
		return if(this.eof() || this.pos + pos > this.stream.length) {
			null;
		} else {
			this.stream.cca(this.pos + pos);
		}
	}

	public function next(length: Int = 1): String {
		if(this.eof() || this.pos + length > this.stream.length) {
			throw "range error!";
		} else {
			return this.stream.substr((this.pos += length) - length, length);
		}
	}

	public function matchesRx(rx: RegExp) {
		rx.lastIndex = this.pos;
		return rx.test(this.stream);
	}

	public function matchRx(rx: RegExp) {
		rx.lastIndex = this.pos;
		final match = rx.exec(this.stream);
		if(match != null) {
			this.pos += match[0].length;
			return match;
		} else {
			throw "did not match!";
		}
	}

	public function tryMatchRx(rx: RegExp) {
		rx.lastIndex = this.pos;
		final match = rx.exec(this.stream);
		return if(match != null) {
			this.pos += match[0].length;
			match;
		} else {
			null;
		}
	}

	public function matches(str: String) {
		return this.stream.startsWith(str, this.pos);
	}

	public function match(str: String) {
		if(this.matches(str)) {
			this.pos += str.length;
			return str;
		} else {
			throw "did not match!";
		}
	}

	public function matchSubstr(str: String): Null<String> {
		final index = this.stream.indexOf(str, this.pos);
		if(index == -1) {
			return null;
		} else {
			final start = this.pos;
			this.pos = index + str.length;
			return this.stream.substring(start, index);
		}
	}

	public function tryMatch(str: String) {
		return if(this.matches(str)) {
			this.pos += str.length;
			true;
		} else {
			false;
		}
	}

	public function trimSpace() {
		// just reuse StringActions.WHITE_CHAR set
		while(runtime.actions.datatypes.StringActions.WHITE_CHAR.has(this.stream.cca(this.pos))) this.pos++;
	}

	public function getLoc() {
		var line = 1;
		var column = 0;

		for(i in this.pos...this.stream.length) {
			switch this.stream.cca(i) {
				case 10 | 13: // FIX
					line++;
					column = 0;
				default:
					column++;
			}
		}

		return {line: line, column: column};
	}

	public function getLocStr() {
		final loc = this.getLoc();
		return '[${loc.line}:${loc.column}]';
	}
}
