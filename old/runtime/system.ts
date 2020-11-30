import * as Red from "../red-types";
import {Ref} from "../helper-types";

export const system = new Red.RawObject();
export const system$words = new Red.RawObject();
export const system$options = new Red.RawObject();
export const system$std = new Red.RawObject();

Red.Context.$.addWord("system", system);

system.addWord("words", system$words);
system.addWord("options", system$options);
system.addWord("standard", system$std);

/* system/options */
system$options.addWord("path", new Red.RawFile(new Ref("./")));
system$options.addWord("args", Red.RawNone.none);

/* system/words */
function addDatatype(name: string) {
	system$words.addWord(name, Red.Datatypes[name]);
}

addDatatype("red-value!");
addDatatype("datatype!");

// scalars
addDatatype("word!");
addDatatype("lit-word!");
addDatatype("get-word!");
addDatatype("set-word!");

addDatatype("path!");
addDatatype("lit-path!");
addDatatype("get-path!");
addDatatype("set-path!");

addDatatype("refinement!");
addDatatype("issue!");

addDatatype("integer!");
addDatatype("float!");
addDatatype("money!");
addDatatype("percent!");
addDatatype("char!");
addDatatype("logic!");
addDatatype("none!");

// series
addDatatype("binary!");
addDatatype("string!");
addDatatype("paren!");
addDatatype("block!");
addDatatype("file!");
addDatatype("url!");
addDatatype("vector!");
addDatatype("hash!");

// compound
addDatatype("email!");
addDatatype("pair!");
addDatatype("date!");
addDatatype("tuple!");
addDatatype("map!");
addDatatype("time!");
addDatatype("tag!");

// other
addDatatype("bitset!");
addDatatype("typeset!");
addDatatype("unset!");

addDatatype("context!");
addDatatype("object!");

addDatatype("function!");
addDatatype("op!");
addDatatype("native!");
addDatatype("action!");

// typesets
system$words.addWord(
	"number!",
	new Red.RawTypeset(
		"integer! float! percent!"
			.split(/\s+/)
			.map(n => Red.Datatypes[n])
	)
);

system$words.addWord(
	"any-word!",
	new Red.RawTypeset(
		"word! set-word! lit-word! get-word!"
			.split(/\s+/)
			.map(n => Red.Datatypes[n])
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

system$words.addWord(
	"any-type!",
	new Red.RawTypeset(types.split(/\s+/).map(n => Red.Datatypes[n]))
);