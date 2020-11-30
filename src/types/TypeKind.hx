package types;

enum abstract TypeKind(Int) {
	var DDatatype;
	var DUnset;
	var DNone;
	var DLogic;
	var DBlock;
	var DParen;
	var DString;
	var DFile;
	var DUrl;
	var DChar;
	var DInteger;
	var DFloat;
	//var DSymbol;
	//var DContext;
	var DWord;
	var DSetWord;
	var DLitWord;
	var DGetWord;
	var DRefinement;
	var DIssue;
	var DNative;
	var DAction;
	var DOp;
	var DFunction;
	var DPath;
	var DLitPath;
	var DSetPath;
	var DGetPath;
	//var DRoutine;
	var DBitset;
	//var DPoint;
	var DObject;
	var DTypeset;
	var DError;
	//var DVector;
	var DHash;
	var DPair;
	var DPercent;
	var DTuple;
	var DMap;
	var DBinary;
	//var DSeries;
	var DTime;
	var DTag;
	var DEmail;
	//var DHandle;
	var DDate;
	//var DPort;
	//var DImage;
	//var DEvent;
	//var DClosure;
	//var DMoney;
	var DRef;

	public inline function isAnyFunction() {
		return switch cast this {
			case DNative | DAction | DFunction | DOp: true;
			default: false;
		}
	}
}