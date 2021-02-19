package util;

using util.NullTools;

private typedef _SetRepr<T> =
	#if js
		js.lib.Set<T>
	#elseif python
		python.Set<T>
	#elseif (neko || hl)
		Map<T, Bool>
	#else
		Array<T>
	#end;

private class _Set<T> {
	var repr: _SetRepr<T>;
	public var length(get, default): Int;
	
	function new(?repr: _SetRepr<T>) {if(repr != null) this.repr = repr;}

	function init(values: Iterable<T>) {
		#if (js || python)
			this.repr = new _SetRepr<T>(values);
		#elseif (neko || hl)
			this.repr = [for(val in values) val => true];
		#else
			this.repr = [for(val in values) val]; // FIX: this allows repeated values
		#end

		return this;
	}

	#if !(neko || hl) inline #end
	function get_length() {
		return #if js
			this.repr.size;
		#elseif neko
			untyped __dollar__hcount(@:privateAccess (cast this.repr : haxe.ds.ObjectMap<{}, Bool>).h);
		#elseif hl
			/*if(this.repr is haxe.ds.ObjectMap<T, Bool>) {
				return @:privateAccess (cast this.repr : haxe.ds.ObjectMap<{}, Bool>).h.valuesArray().length;
			}*/
			@:privateAccess (cast this.repr.iterator() : hl.NativeArray.NativeArrayIterator<Bool>).length;
		#else
			this.repr.length;
		#end
	}

	public function add(value: T) {
		#if (js || python)
			this.repr.add(value);
		#elseif (neko || hl)
			this.repr[value] = true;
		#else
			if(!this.repr.contains(value)) {
				this.repr.push(value);
			}
		#end

		return this;
	}

	public inline function has(value: T) {
		return #if (js || python)
			this.repr.has(value);
		#elseif (neko || hl)
			this.repr.exists(value);
		#else
			this.repr.contains(value);
		#end
	}

	public inline function remove(value: T) {
		return #if js
			this.repr.delete(value);
		#elseif (neko || hl)
			this.repr.remove(value);
		#else
			throw "todo!";
		#end
	}

	public function filter(cond: T -> Bool) {
		return new _Set<T>().init(
			#if (js || python)
				[for(v in this.repr) if(cond(v)) v]
			#elseif (neko || hl)
				[for(k in this.repr.keys()) if(cond(k)) k]
			#else
				this.repr.filter(cond)
			#end
		);
	}

	public function map<U>(fn: T -> U) {
		return new _Set<U>().init([for(v in this.iterator()) fn(v)]);
	}

	public inline function iterator(): Iterator<T> {
		return #if (neko || hl)
			this.repr.keys();
		#else
			this.repr.iterator();
		#end
	}

	// ...

	public function copy() {
		return new _Set<T>(
			#if js
				new _SetRepr<T>(this.repr)
			#else
				this.repr.copy()
			#end
		);
	}
}

abstract Set<T>(_Set<T>) from _Set<T> to Iterable<T> {
	public var length(get, never): Int;
	inline function get_length() return this.length;

	public function new(?values: Iterable<T>) {
		@:privateAccess
		this = new _Set<T>().init((values == null) ? [] : values);
	}

	@:op([])
	public inline function has(value: T) return this.has(value);

	@:op([])
	public function set(value: T, cond: Bool) {
		if(cond) this.add(value) else this.remove(value);
	}

	public inline function add(value: T): Set<T> return this.add(value);

	public inline function remove(value: T) return this.remove(value);

	public inline function filter(cond: T -> Bool): Set<T> return this.filter(cond);
	
	public inline function map<U>(fn: T -> U): Set<U> return this.map(fn);
	
	public inline function iterator() return this.iterator();
	
	public inline function copy(): Set<T> return this.copy();

	@:to
	public inline function toArray() return [for(value in this) value];
}