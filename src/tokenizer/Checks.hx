package tokenizer;

class Checks {
	public static function anyWord(rdr: Reader) {
		return rdr.matchesRx(RegexpChecks.word) || rdr.matchesRx(RegexpChecks.specialWord);
	}
}