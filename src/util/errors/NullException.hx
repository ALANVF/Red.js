package util.errors;

import haxe.*;
import haxe.exceptions.*;

class NullException extends PosException {
	public function new(?message: String, ?previous: Exception, ?pos: PosInfos): Void {
		final msg = message == null
			? "Value was null"
			: message;
			
		super(msg, previous, pos);
	}
}