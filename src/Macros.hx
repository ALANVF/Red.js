@:publicFields
class Macros {
	static macro function processSetVirtual(bs, bit) {
		return macro if(isNot) {
			if(isVirtualBit($bs, $bit)) return 1;
		} else {
			boundCheck($bs, $bit);
		};
	}

	static macro function processClearVirtual(bs, bit) {
		return macro if(isNot) {
			boundCheck($bs, $bit);
		} else {
			if(isVirtualBit($bs, $bit)) return 0;
		}
	}

	static macro function getBuild() {
		final date = Date.now();
		final res = '${date.getFullYear()}.${date.getMonth()}.${date.getDate()}';
		return macro $v{res};
	}
}