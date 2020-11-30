package util;

abstract ERegTools(EReg) from EReg to EReg {
	public static function matchedGroups(rx: EReg): Array<String> {
#if js
		return @:privateAccess [for(v in rx.r.m) v];
#else // add more languages later...
		var i = 0;
		var out = [];
		try {
			while(rx.matched(i) != null) out.push(rx.matched(i++));
		} catch(_) {}
		return out;
#end
	}
}