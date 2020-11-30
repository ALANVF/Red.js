package runtime.actions.datatypes;

import types.Unset;

class UnsetActions extends ValueActions {
	override public function make(_, _) return Unset.UNSET;

	override public function to(_, _) return Unset.UNSET;

	override public function form(_, _) return types.String.fromString("");

	override public function mold(_, _) return types.String.fromString("");
}