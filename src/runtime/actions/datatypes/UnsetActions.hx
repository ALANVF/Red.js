package runtime.actions.datatypes;

import types.Unset;

class UnsetActions extends ValueActions<Unset> {
	override function make(_, _) return Unset.UNSET;

	override function to(_, _) return Unset.UNSET;

	override function form(_, _) return types.String.fromString("");

	override function mold(_, _) return types.String.fromString("");
}