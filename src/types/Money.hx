package types;

import util.Dec64;

class Money extends Value {
	public final m: Dec64;
	public final region: Null<Word>;

	public function new(m: Dec64, region: Null<Word>) {
		this.m = m;
		this.region = region;
	}
}