package types.base;

import haxe.ds.Option;


typedef NFunctionOptions = {
	_extern: Bool
}

typedef NSwitchOptions = {
	?_default: {_case: Block}
}

typedef NCaseOptions = {
	all: Bool
}

typedef NDoOptions = {
	expand: Bool,
	?args:  {arg: Value},
	?next:  {position: Word}
}

typedef NReduceOptions = {
	?into: {out: Value}
}

typedef NComposeOptions = {
	deep: Bool,
	only: Bool,
	?into: {out: Value}
}

typedef NGetOptions = {
	any:   Bool,
	_case: Bool
}

typedef NSetOptions = {
	any:   Bool,
	_case: Bool,
	only:  Bool,
	some:  Bool
}

typedef NType_qOptions = {
	word: Bool
}

typedef NStatsOptions = {
	show: Bool,
	info: Bool
}

typedef NBindOptions = {
	copy: Bool
}

typedef NParseOptions = {
	_case:  Bool,
	?part:  {length: Value},
	?trace: {callback: Function}
}

typedef NSetOpOptions = {
	_case: Bool,
	?skip: {size: Integer}
}

typedef NShiftOptions = {
	left:    Bool,
	logical: Bool
}

typedef NToHexOptions = {
	?size: {length: Integer}
}

typedef NTrigOptions = {
	radians: Bool
}

typedef NConstructOptions = {
	?with: {object: Object},
	only:  Bool
}

typedef NTryOptions = {
	all: Bool,
	keep: Bool
}

typedef NChangeCaseOptions = {
	?part: {limit: Value}
}

typedef NBreakOptions = {
	?_return: {value: Value}
}

typedef NThrowOptions = {
	?name: {word: Word}
}

typedef NCatchOptions = {
	?name: {word: Value}
}

typedef NExtendOptions = {
	_case: Bool
}

typedef NBaseOptions = {
	?base: {baseValue: Integer}
}

typedef NToLocalFileOptions = {
	full: Bool
}

typedef NWaitOptions = {
	all: Bool
}

typedef NChecksumOptions = {
	?with: {spec: Value}
}

typedef NNewLineOptions = {
	all:   Bool,
	?skip: {size: Integer}
}

typedef NNowOptions = {
	year:    Bool,
	month:   Bool,
	day:     Bool,
	time:    Bool,
	zone:    Bool,
	date:    Bool,
	weekday: Bool,
	yearday: Bool,
	precise: Bool,
	utc:     Bool
}

typedef NCallOptions = {
	wait:    Bool,
	show:    Bool,
	console: Bool,
	shell:   Bool,
	?input:  {_in: Value},
	?output: {out: Value},
	?error:  {err: Value}
}

typedef NCompressOptions = {
	zlib:    Bool,
	deflate: Bool
}

typedef NDecompressOptions = {
	?zlib:    {size: Integer},
	?deflate: {size: Integer}
}

typedef NRecycleOptions = {
	on:  Bool,
	off: Bool
}

typedef NTranscodeOptions = {
	next:    Bool,
	one:     Bool,
	prescan: Bool,
	scan:    Bool,
	?part:    {length: Value},
	?into:    {dst: Value},
	?trace:   {callback: Function}
}

typedef NApplyOptions = {
	all: Bool,
	safer: Bool
};

typedef _NativeOptions = {}