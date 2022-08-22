package util;

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

private abstract _Set<T>(_SetRepr<T>) {
	public var length(get, never): Int;
	
	inline function new(?repr: _SetRepr<T>) this = repr ?? new _SetRepr<T>();

	static inline function init<T>(values: Iterable<T>) {
		#if (js || python)
			return new _Set<T>(new _SetRepr<T>(values));
		#elseif (neko || hl)
			return new _Set<T>([for(val in values) val => true]);
		#else
			return new _Set<T>([for(val in values) val]); // FIX: this allows repeated values
		#end
	}

	#if !(neko || hl) inline #end
	function get_length() {
		return #if js
			this.size;
		#elseif neko
			untyped __dollar__hcount(@:privateAccess (cast this : haxe.ds.ObjectMap<{}, Bool>).h);
		#elseif hl
			/*if(this.repr is haxe.ds.ObjectMap<T, Bool>) {
				return @:privateAccess (cast this.repr : haxe.ds.ObjectMap<{}, Bool>).h.valuesArray().length;
			}*/
			@:privateAccess (cast this.iterator() : hl.NativeArray.NativeArrayIterator<Bool>).length;
		#else
			this.length;
		#end
	}

	public inline function add(value: T) {
		#if (js || python)
			this.add(value);
		#elseif (neko || hl)
			this[value] = true;
		#else
			if(!this.contains(value)) {
				this.push(value);
			}
		#end

		return abstract;
	}

	public inline function has(value: T) {
		return #if (js || python)
			this.has(value);
		#elseif (neko || hl)
			this.exists(value);
		#else
			this.contains(value);
		#end
	}

	public inline function remove(value: T) {
		return #if js
			this.delete(value);
		#elseif (neko || hl)
			this.remove(value);
		#else
			throw "todo!";
		#end
	}

	public function filter(cond: T -> Bool) {
		return _Set.init(
			#if (js || python)
				[for(v in this) if(cond(v)) v]
			#elseif (neko || hl)
				[for(k in this.keys()) if(cond(k)) k]
			#else
				this.filter(cond)
			#end
		);
	}

	public function map<U>(fn: T -> U) {
		return _Set.init([for(v in iterator()) fn(v)]);
	}

	public inline function iterator(): Iterator<T> {
		return #if (neko || hl)
			this.keys();
		#else
			this.iterator();
		#end
	}

	// ...

	public inline function copy() {
		return new _Set<T>(
			#if js
				new _SetRepr<T>(this)
			#else
				this.copy()
			#end
		);
	}
}

abstract Set<T>(_Set<T>) from _Set<T> {
	public var length(get, never): Int;
	inline function get_length() return this.length;

	public inline function new(?values: Iterable<T>) {
		this = @:privateAccess inline _Set.init(values ?? cast []);
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