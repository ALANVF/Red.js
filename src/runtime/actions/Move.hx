package runtime.actions;

import types.base.Options;
import types.base._ActionOptions;
import types.Value;

@:build(runtime.ActionBuilder.build())
class Move {
	public static final defaultOptions = Options.defaultFor(AMoveOptions);

	public static function call(origin: Value, target: Value, options: AMoveOptions) {
		return Actions.getFor(origin).move(origin, target, options);
	}
}