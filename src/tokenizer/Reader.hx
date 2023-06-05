package tokenizer;

using StringTools;
using util.ERegTools;

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

	public function matchesRx(rx: EReg) {
		//return rx.match(this.stream.substr(this.pos)) && rx.matchedPos().pos == 0;
		return rx.matchSub(this.stream, this.pos) && rx.matchedPos().pos == this.pos;
	}

	public function matchRx(rx: EReg) {
		if(this.matchesRx(rx)) {
			this.pos += rx.matchedPos().len;
			return rx.matchedGroups();
		} else {
			throw "did not match!";
		}
	}

	public function tryMatchRx(rx: EReg) {
		return if(this.matchesRx(rx)) {
			this.pos += rx.matchedPos().len;
			rx.matchedGroups();
		} else {
			null;
		}
	}

	public function matches(str: String) {
		return this.stream.substr(this.pos).startsWith(str);
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
		while(this.stream.isSpace(this.pos)) this.pos++;
	}

	public function getLoc() {
		var line = 1;
		var column = 0;

		for(char in this.stream.substr(0, this.pos).iterator()) {
			switch char {
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
