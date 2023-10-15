package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.base._SeriesOf;
import types.base._BlockLike;
import types.base._String;
import types.base._Integer;
import types.Value;
import types.Integer;
import types.Char;
import types.Pair;
import types.Logic;
import types.None;
import types.Binary;

import runtime.actions.datatypes.ValueActions.invalid;

class SeriesActions<This: _SeriesOf<Elem, Val>, Elem: Value, Val> extends ValueActions<This> {
	/*-- Series actions --*/

	override function at(series: This, index: Value): This {
		final i = index._match(
			at(int is Integer) => int.int,
			at(pair is Pair) => pair.x,
			_ => throw "bad"
		);

		return cast series.at(i);
	}

	override function back(series: This): This {
		return cast series.skip(-1);
	}

	override function change(series: This, value: Value, options: AChangeOptions) {
		var cnt = (options.dup?.count)._andOr(count => {
			final int = count.asInt();
			if(int < 1) return series;
			int;
		}, {
			1;
		});

		// TODO
		//if(options.part != null) throw "I have no fucking clue how this works";

		var isNeg = false;
		var isSelf = false;
		final s = series.values;
		var head = series.index;
		var size = series.length;

		final isBlk = series is _BlockLike;

		final series2 = (cast value : _SeriesOf<Elem, Val>);
		final isValues = if(options.only && isBlk) false else {
			isSelf = value.thisType() == series.thisType() && series.values == series2.values;
		};

		var cell: Any;
		var cellIdx: Int;
		var items = if(isSelf || isValues) {
			final s2 = series2.values;
			cell = s2;
			cellIdx = series2.index;
			series2.length;
		} else {
			cell = value;
			cellIdx = 0;
			1;
		};
		final limit = cellIdx + items;

		var part = items;
		final hasPart = options.part != null;
		(options.part?.range)._andOr(range => {
			part = range._match(
				at(int is Integer) => int.int,
				at(ser2 is _SeriesOf<Elem, Val>) => {
					if(!(ser2.thisType() == series.thisType() && ser2.values == series.values)) {
						throw "bad";
					}
					ser2.index - head;
				},
				_ => throw "bad"
			);
			if(part < 0) {
				part = -part;
				if(part > head) {
					part = head;
					head = 0;
				} else {
					head -= part;
				}
				series.index = head;
				isNeg = true;
			}
			size -= head;
			if(part > size) part = size;
		}, {
			size -= head;
		});

		var allAdded = 0;

		if(isBlk || isSelf) {
			// TODO: all of this fucking sucks please rewrite it
			var n = if(hasPart) part else items * cnt;
			if(n > size) n = size;

			final added = if(hasPart) items - part else items - size;
			n = series.length + added;
			if(n > series.absLength) for(_ in 0...(n - series.absLength)) {
				s.insert(head, null);
			}
			
			if(hasPart) {
				size -= part;
				s.splice(head, part);
			}
			
			cell._match(
				at(s2 is Array<Val>) => {
					if(hasPart) for(_ in 0...s2.length) s.insert(head,null);
					for(i in 0...(allAdded=s2.length)) s[head + i] = s2[cellIdx + i];
				},
				at(blk is _BlockLike) => {
					if(hasPart) for(_ in 0...blk.length) s.insert(head,null);
					for(i in blk.index...(allAdded=blk.length)) s[head + i] = cast blk.rawFastPick(i);
				},
				at(val is Value) => {
					if(hasPart) for(_ in 0...part) s.insert(head, null);
					s.fill(cast val, head, allAdded = head + items);
				},
				_ => throw "bad"
			);

			// I'm too lazy to fix this
			if(hasPart) while(s.contains(null)) s.remove(null);
		} else {
			if(hasPart) {
				size -= part;
				s.splice(head, part);
			}
			final a = {ref: 0};
			items = series._match(
				at(str is _String) => StringActions.changeRange(str, cell, cellIdx, a, limit, hasPart),
				_ => throw "bad"
			);

			allAdded = a.ref;
		}

		if(cnt > 1) {
			var src = series.index;
			var tail = series.absLength;

			final added = items;
			var n = added * cnt;
			n = if(hasPart) n - added else src + n - tail;
			size = (tail - series.index) + n;
			/*if(size > series.absLength) {
				for(_ in 0...(size - series.absLength)) {
					s.insert(head, null);
					tail++;
				}
			}*/

			src += added;
			
			// TODO: all of this fucking sucks, either optimize it or burn it with fire

			/*items *= cnt;
			var p = src;
			src -= added;
			do {
				for(i in 0...added) {trace(p, src); s[p + i] = s[src + i];}
				p += added;
				cnt--;

			} while(cnt != 1);*/

			/*for(i in 1...cnt) {
				for(j in 0...allAdded) {
					final k = head + allAdded + (j * i);
					trace(i,j,k,head+j);
					//trace(s[k], s[head+j]);
					s[k] = s[head + j];
				}
				if(s[head+allAdded*2+1] == null) break;
			}*/

			final orig = s.slice(head, head + allAdded);

			if(hasPart) {
				//s.splice(head, part-1);
				for(_ in 0...((cnt-1)*allAdded)) s.insert(head+allAdded, null);
			}

			for(c in 1...cnt) {
				for(i in 0...orig.length) {
					s[head + (allAdded * c) + i] = orig[i];
				}
			}

		}

		series.index += items;
		return series;
	}

	override function clear(series: This): This {
		series.values.splice(series.index, series.values.length - series.index);
		return series;
	}

	override function copy(series: This, options: ACopyOptions): This {
		final s = series.values;
		var offset = series.index;
		final len = series.absLength;
		var part = (len - offset).max(0);

		if(options.types != null) throw "NYI";
		
		options.part?.length._and(p => {
			part = p._match(
				at(i is Integer) => i.int,
				at({x: x, y: y} is Pair) => {
					offset += x - 1;
					if(x < 0) offset++;
					if(offset < 0) offset = 0;
					if(y < x) 0 else y - x;
				},
				at(s is _SeriesOf<Elem, Val>) => {
					if(series.values != s.values) invalid();
					s.index - series.index;
				},
				_ => invalid()
			);
			if(part < 0) {
				part *= -1;
				offset -= part;
				if(offset < 0) {
					offset = 0;
					part = series.index;
				}
			}
		});

		if(offset > len) {
			part = 0;
			offset = len;
		}
		if(offset + part > len) {
			part = len - offset;
		}
		
		return cast @:privateAccess series.clone(s.slice(offset, offset + part));
	}

	override function head(series: This): This {
		return cast series.head();
	}

	override function head_q(series: This): Logic {
		return Logic.fromCond(series.isHead());
	}

	override function index_q(series: This): Integer {
		return new Integer(series.index);
	}

	override function length_q(series: This): Integer {
		return new Integer(series.length);
	}

	override function move(origin: This, target: Value, options: AMoveOptions) {
		final tail = origin.absLength;
		var part = 1;
		var items = 1;
		if(origin.index == tail) return target;

		options.part?.length._and(length => {
			part = length.int;
			if(part <= 0) return target;
			final limit = origin.length;
			if(part > limit) part = limit;
			items = part;
		});

		if(origin.thisType() == target.thisType()) {
			final src = origin.values;
			final srcIdx = origin.index;
			final tgt = (cast target : This);
			final dst = tgt.values;
			var dstIdx = tgt.index;
			if(src == dst) return target;
			// TODO: figure out why tail - dstIdx doesn't work here. this whole thing is rly stupid
			if(dstIdx > srcIdx && dstIdx != tail && part > tail - srcIdx) {
				return origin;
			}
			if(dstIdx > tail) dstIdx = tail;
			dst.insertAll(dstIdx, ...src.splice(srcIdx, part));
		} else {
			// TODO: add vector cases
			if((origin is _BlockLike && target is _String)
			|| (origin is _String && target is _BlockLike)) {
				throw "bad";
			}

			// TODO: get rid of stupid code duplication
			target._match(
				at(tgt is _BlockLike) => {
					final src = (cast origin : _BlockLike).values;
					final srcIdx = origin.index;
					final dst = tgt.values;
					var dstIdx = tgt.index;
					if(src == dst) return target;
					if(dstIdx > tail) dstIdx = tail;

					dst.insertAll(dstIdx, ...src.splice(srcIdx, part));
				},
				at(tgt is _String) => {
					final src = (cast origin : _String).values;
					final srcIdx = origin.index;
					final dst = tgt.values;
					var dstIdx = tgt.index;
					if(src == dst) return target;
					if(dstIdx > tail) dstIdx = tail;

					dst.insertAll(dstIdx, ...src.splice(srcIdx, part));
				},
				_ => throw "bad"
			);
		}

		return origin;
	}

	override function next(series: This): This {
		return cast series.skip(1);
	}

	override function pick(series: This, index: Value): Value {
		return index._match(
			at({int: idx} is Integer) => {
				idx--;
				series._match(
					at(b is _BlockLike) => b.pick(idx) ?? cast None.NONE,
					// Vector
					at(b is Binary) => b.pick(idx) ?? cast None.NONE,
					at(s is _String) => s.pick(idx) ?? cast None.NONE,
					_ => invalid()
				);
			},
			_ => invalid()
		);
	}

	override function poke(series: This, index: Value, value: Value): Value {
		index._match(
			at({int: idx} is Integer) => {
				idx--;
				cast series._match(
					// Hash
					at(b is _BlockLike) => b.rawPoke(idx, value),
					at(b is Binary) => value._match(
						at(i is _Integer) => cast b.rawPoke(idx, i.int),
						_ => invalid()
					),
					// Vector
					at(s is _String) => value._match(
						at(c is Char) => cast s.rawPoke(idx, c.int),
						_ => invalid()
					),
					_ => invalid()
				) ?? throw "out of range";
			},
			_ => invalid()
		);
		return value;
	}

	override function skip(series: This, offset: Value): This {
		final i = offset._match(
			at(int is Integer) => int.int,
			at(pair is Pair) => pair.x,
			_ => throw "bad"
		);

		return cast series.skip(i);
	}

	override function remove(series: This, options: ARemoveOptions) {
		var part = 1;
		var items = 1;

		options.part?.length._and(len => {
			part = len._match(
				at(i is Integer) => i.int,
				at(series2 is _SeriesOf<Elem, Val>) => {
					if(series2.thisType() == series.thisType() && series2.values == series.values) {
						throw "bad";
					}
					series2.index - series.index;
				},
				_ => throw "bad"
			);
			if(part <= 0) return series;
			items = part;
		});

		options.key?.keyArg._and(key => {
			throw "NYI";
		});

		series.values.splice(series.index, items);

		return series;
	}

	override function reverse(series: This, options: AReverseOptions) {
		// fast path
		if(series.index == 0 && options.part == null && options.skip == null) {
			series.values.reverse();
			return series;
		}

		var part = 0;
		(options.part?.length)._and(len => {
			part = len._match(
				at(i is Integer) => i.int,
				at(series2 is _SeriesOf<Elem, Val>) => {
					if(series2.thisType() == series.thisType() && series2.values == series.values) {
						throw "bad";
					}
					series2.index - series.index;
				},
				_ => throw "bad"
			);
			if(part <= 0) return series;
		});
		final s = series.values;
		final last = series.absLength - 1;
		final minIndex = series.index;
		final maxIndex = part == 0 ? last : (part - 1).min(last);

		if(minIndex > maxIndex) return series;
		
		final length = maxIndex - minIndex;
		final half = Math.floor(length / 2).max(1);
		
		(options.skip?.size)._andOr(size => {
			final skip = size.int;

			if(skip == series.length) return series;
			if(skip <= 0) throw "bad";
			if(skip > maxIndex || (maxIndex-1) % skip != 0) throw "bad";

			for(i in 0...half) {
				for(j in 0...skip) {
					final idx1 = minIndex + i + j;
					final idx2 = maxIndex - i - skip + j + 1;
					js.Syntax.code("[{0}, {1}] = [{1}, {0}]", s[idx1], s[idx2]);
				}
			}
		}, {
			for(i in 0...half) {
				final idx1 = minIndex + i;
				final idx2 = maxIndex - i;
				js.Syntax.code("[{0}, {1}] = [{1}, {0}]", s[idx1], s[idx2]);
			}
		});

		return series;
	}

	override function swap(series1: This, series2: Value): This {
		if(series1.length == 0) return series1;
		series2._match(
			at(s2 is _String) => {
				if(s2.length == 0) return series1;
				final s1 = (cast series1 : _String);
				final char1 = s1.rawFastPick(0);
				final char2 = s2.rawFastPick(0);
				s1.rawFastPoke(0, char2);
				s2.rawFastPoke(0, char1);
				return series1;
			},
			_ => throw "bad"
		);
	}

	override function tail(series: This): This {
		return cast series.tail();
	}

	override function tail_q(series: This): Logic {
		return Logic.fromCond(series.isTail());
	}

	override function take(series: This, options: ATakeOptions): Value {
		var size = series.length;
		if(size <= 0) return None.NONE;

		var part = 1;
		var part2 = 1;
		var ser2 = null;
		final hasPart = (options.part?.length)._andOr(p => {
			part = p._match(
				at(i is Integer) => i.int,
				at(s is _SeriesOf<Elem, Val>) => {
					if(!series.sameSeriesAs(s)) throw "bad";
					ser2 = s;
					if(ser2.index < series.index) 0;
					else if(options.last) size - (ser2.index - series.index);
					else ser2.index - series.index;
				},
				_ => invalid()
			);
			part2 = part;
			if(part < 0) {
				size = series.index;
				part = if(options.last) 1 else -part;
			}
			true;
		}, {
			false;
		});

		if(!hasPart) {
			return if(options.last) {
				cast @:privateAccess series.wrap(series.values.pop());
			} else if(series.index == 0) {
				cast @:privateAccess series.wrap(series.values.shift());
			} else {
				cast @:privateAccess series.wrap(series.values.splice(series.index, 1)[0]);
			}
		}

		var offset = series.index;
		
		if(part2 > 0) {
			if(options.last) {
				offset = series.length - part;
			}
		} else {
			if(options.last || part > series.absLength) return @:privateAccess series.clone([]);
			offset -= part;
		}

		return @:privateAccess series.clone(series.values.splice(offset, part));
	}
}