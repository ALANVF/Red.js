package util;

import haxe.macro.Expr;

private typedef Ctx = {
	public function getLocalTVars(): Map<String, haxe.macro.Type.TVar>;
	public function currentPos(): Position;
};

class ContextTools {
	public static function newTempVar(context: Ctx) {
		final vars = context.getLocalTVars();
		final allNames = [for(v => _ in vars) v];
		final allTmps = allNames.filter(name -> name.indexOf("_tmp") == 0);
		return if(allTmps.length == 0) {
			'_tmp';
		} else {
			var i = 0;
			while(allTmps.contains('_tmp$i')) i++;
			'_tmp$i';
		};
	}
}