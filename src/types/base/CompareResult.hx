package types.base;

enum abstract CompareResult(Int) {
	var IsInvalid = -2;
	var IsLess = -1;
	var IsSame = 0;
	var IsMore = 1;
}