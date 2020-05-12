import * as Red from "../red-types";

export const system  = new Red.Context("system", Red.Context.$);
export const system$ = new Red.RawWord("system");

Red.Context.$.setWord(system$, system);
//Red.Context.$.setWord(system$, system);

export const system$words = new Red.RawWord("words");
const system$options = new Red.RawWord("options");
const system$std = new Red.RawWord("standard");

function addDatatype(name: string, datatype: Function) {
	system.setPath(
		new Red.RawPath([system$words, new Red.RawWord(name)]),
		new Red.RawDatatype(name, datatype)
	);
}

system.setWord(system$options, new Red.Context("options", system));
system.setWord(system$words, new Red.Context("words", system));
system.setWord(system$std, new Red.RawNone());

/* system/options */
system.setPath(new Red.RawPath([system$options, new Red.RawWord("path")]), new Red.RawFile("./"));
system.setPath(new Red.RawPath([system$options, new Red.RawWord("args")]), new Red.RawNone());

/* system/words */
addDatatype("red-value!", Red.RawValue);
addDatatype("datatype!", Red.RawDatatype);

// scalars
addDatatype("word!", Red.RawWord);
addDatatype("lit-word!", Red.RawLitWord);
addDatatype("get-word!", Red.RawGetWord);
addDatatype("set-word!", Red.RawSetWord);

addDatatype("path!", Red.RawPath);
addDatatype("lit-path!", Red.RawLitPath);
addDatatype("get-path!", Red.RawGetPath);
addDatatype("set-path!", Red.RawSetPath);

addDatatype("refinement!", Red.RawRefinement);
addDatatype("issue!", Red.RawIssue);

addDatatype("integer!", Red.RawInteger);
addDatatype("float!", Red.RawFloat);
addDatatype("money!", Red.RawMoney);
addDatatype("percent!", Red.RawPercent);
addDatatype("char!", Red.RawChar);
addDatatype("logic!", Red.RawLogic);
addDatatype("none!", Red.RawNone);

// series
addDatatype("binary!", Red.RawBinary);
addDatatype("string!", Red.RawString);
addDatatype("paren!", Red.RawParen);
addDatatype("block!", Red.RawBlock);
addDatatype("file!", Red.RawFile);
addDatatype("url!", Red.RawUrl);
addDatatype("vector!", Red.RawVector);
addDatatype("hash!", Red.RawHash);

// compound
addDatatype("email!", Red.RawEmail);
addDatatype("pair!", Red.RawPair);
addDatatype("date!", Red.RawDate);
addDatatype("tuple!", Red.RawTuple);
addDatatype("map!", Red.RawMap);
addDatatype("time!", Red.RawTime);
addDatatype("tag!", Red.RawTag);

// other
addDatatype("bitset!", Red.RawBitset);
addDatatype("typeset!", Red.RawTypeset);
addDatatype("unset!", Red.RawUnset);

addDatatype("context!", Red.Context);
addDatatype("object!", Red.RawObject);

addDatatype("function!", Red.RawFunction);
addDatatype("op!", Red.Op);
addDatatype("native!", Red.Native);
addDatatype("action!", Red.Action);

// typesets
system.setPath(
	new Red.RawPath([system$words, new Red.RawWord("number!")]),
	new Red.RawTypeset(
		"integer! float! percent! money!"
			.split(/\s+/)
			.map(n => system.getPath(new Red.RawPath([system$words, new Red.RawWord(n)])) as Red.RawDatatype)
	)
);

system.setPath(
	new Red.RawPath([system$words, new Red.RawWord("any-word!")]),
	new Red.RawTypeset(
		"word! set-word! lit-word! get-word!"
			.split(/\s+/)
			.map(n => system.getPath(new Red.RawPath([system$words, new Red.RawWord(n)])) as Red.RawDatatype)
	)
);

/*
const types = `
	datatype! unset! none! logic! block! paren! string! file! url!
	char! integer! float! word! set-word! lit-word! get-word! refinement! issue! native! action! op! function! path! lit-path! set-path! get-path!
;	routine!
	bitset! object! typeset!
;	error!
	vector!
	hash!
	pair! percent! tuple!
	map! binary!
	time!
	tag!
	email!
;	handle!
	date!
;	image! event!`.trim();

system.setPath(
	new Red.RawPath([system$words, new Red.RawWord("any-type!")]),
	new Red.RawTypeset([].concat(types.split(/\n/).filter(l => !l.startsWith(";")).map(l => l.split(/\s+/))).map(n => new Red.RawWord(n)))
);
*/

const types = `
	datatype! unset! none! logic! block! paren! string! file! url!
	char! integer! float! money!
	word! set-word! lit-word! get-word! refinement! issue!
	path! lit-path! set-path! get-path!
	native! action! op! function!
	bitset! object! typeset! vector! hash! map! binary!
	pair! percent! tuple!
	time!
	tag! email!
	date!`.trim();

system.setPath(
	new Red.RawPath([system$words, new Red.RawWord("any-type!")]),
	new Red.RawTypeset(
		types
			.split(/\s+/)
			.map(n => system.getPath(new Red.RawPath([system$words, new Red.RawWord(n)])) as Red.RawDatatype)
	)
);