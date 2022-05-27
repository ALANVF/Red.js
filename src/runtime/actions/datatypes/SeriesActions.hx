package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.base._SeriesOf;
import types.Value;
import types.Integer;
import types.Pair;
import types.Logic;

class SeriesActions<This: _SeriesOf<Elem>, Elem: Value> extends ValueActions<This> {
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

	override function next(series: This): This {
		return cast series.skip(1);
	}

	override function skip(series: This, offset: Value): This {
		final i = offset._match(
			at(int is Integer) => int.int,
			at(pair is Pair) => pair.x,
			_ => throw "bad"
		);

		return cast series.skip(i);
	}

	override function tail(series: This): This {
		return cast series.tail();
	}

	override function tail_q(series: This): Logic {
		return Logic.fromCond(series.isTail());
	}
}