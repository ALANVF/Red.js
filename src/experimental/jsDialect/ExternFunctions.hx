package experimental.jsDialect;

class ExternFunctions {
	public static final _eval = new ExternFunction(["eval"], [KAny], KAny);
	public static final _isFinite = new ExternFunction(["isFinite"], [KAny], KBoolean);
	public static final _isNaN = new ExternFunction(["isNaN"], [KAny], KBoolean);
	public static final _parseFloat = new ExternFunction(["parseFloat"], [KAny], KNumber);
	public static final _parseInt = new ExternFunction(["parseInt"], [KAny, KOpt(KNumber)], KNumber);
	public static final _encodeURI = new ExternFunction(["encodeURI"], [KAny], KString);
	public static final _encodeURIComponent = new ExternFunction(["encodeURIComponent"], [KAny], KString);
	public static final _decodeURI = new ExternFunction(["decodeURI"], [KAny], KString);
	public static final _decodeURIComponent = new ExternFunction(["decodeURIComponent"], [KAny], KString);

	// ...
	
	//public static final _Number_isNaN = new ExternFunction(["Number", "isNaN"], [KAny], KBoolean);
}