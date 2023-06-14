package runtime.actions.datatypes;

import types.base.CompareResult;
import types.base.ComparisonOp;
import types.base._ActionOptions;
import types.Value;
import types.File;
import types.Integer;
import types.Pair;
import types.Logic;
import types.String;

class FileActions extends StringActions<File> {
	override function mold(
		value: File, buffer: String,
		isOnly: Bool, isAll: Bool, isFlat: Bool,
		arg: Null<Int>, part: Int,
		indent: Int
	) {
		final limit = arg ?? 0;

		final head = value.index;
		var p = head;
		final isEmpty = p == value.absLength;

		final tail = (
			if(limit == 0) value.absLength
			else if(part < 0) p
			else (p + part).min(value.absLength)
		);
		
		buffer.appendChar('%'.code);
		if(isEmpty) {
			buffer.appendLiteral('""');
		} else {
			// prescan for special characters
			while(p < tail) {
				final cp = value.values[p];
				if(cp < StringActions.URL_ENCODE_TBL.length && StringActions.URL_ENCODE_TBL[cp] == 0) {
					break;
				}
				p++;
			}
			final isEsc = p < tail;
			p = head;
			if(isEsc) buffer.appendChar('"'.code);
			while(p < tail) {
				final cp = value.values[p];
				buffer.appendChar(cp);
				p++;
			}
			if(isEsc) buffer.appendChar('"'.code);
		}
		return part - (tail - head) - 1;
	}
}