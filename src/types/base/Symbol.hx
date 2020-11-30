package types.base;

using util.NullTools;

class Symbol extends Value {
	public final name: std.String;
	public var context: Context;
	public var offset: Int;

	public function new(name: std.String, ?context: Context, ?offset: Int) {
		this.name = name;
		this.context = context.getOrElse(Context.GLOBAL);
		if(offset == null) {
			this.context.addSymbol(this);
		} else {
			this.offset = offset;
		}
	}

	public function equalsString(str: std.String, ignoreCase = true) {
		return ignoreCase
			? this.name.toLowerCase() == str.toLowerCase()
			: this.name == str;
	}

	public function equalsSymbol(sym: Symbol) {
		return this.name.toLowerCase() == sym.name.toLowerCase();
	}

	public function copyWith(?context: Context, ?offset: Int): Symbol {
		throw "must be implemented by subclasses!";
	}

	public function bindToContext(ctx: Context) {
		if(this.context != ctx) {
			switch ctx.offsetOf(this.name) {
				case -1:
					final value = this.getValue(true);
					ctx.addSymbol(this);
					ctx.setSymbol(this, value);
				case offset:
					this.context = ctx;
					this.offset = offset;
			}
		}

		return this;
	}

	public function getValue(?optional: Bool = false) {
		switch this.context.getSymbol(this) {
			case Unset.UNSET if(!optional):
				throw 'Word `${this.name}` doesn\'t exist!';
			case value:
				return value;
		}
	}

	public function setValue(value: Value) {
		if(!context.containsSymbol(this)) {
			Context.GLOBAL.addSymbol(this);
		}
		
		return context.setSymbol(this, value);
	}
}