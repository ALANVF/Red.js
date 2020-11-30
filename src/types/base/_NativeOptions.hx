package types.base;

import haxe.ds.Option;

using util.OptionTools;

typedef NFunctionOptions = {
	_extern: Bool
}

typedef NSwitchOptions = {
	_default: Option<{_case: Block}>
}

typedef NCaseOptions = {
	all: Bool
}

typedef NDoOptions = {
	expand: Bool,
	args:   Option<{arg: Value}>,
	next:   Option<{position: Word}>
}

typedef NReduceOptions = {
	into: Option<{out: Value}>
}

typedef NComposeOptions = {
	deep: Bool,
	only: Bool,
	into: Option<{out: Value}>
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
	_case: Bool,
	part:  Option<{length: Value}>,
	trace: Option<{callback: Function}>
}

typedef NSetOpOptions = {
	_case: Bool,
	skip:  Option<{size: Integer}>
}

typedef NShiftOptions = {
	left:    Bool,
	logical: Bool
}

typedef NToHexOptions = {
	size: Option<{length: Integer}>
}

typedef NTrigOptions = {
	radians: Bool
}

typedef NConstructOptions = {
	with: Option<{object: Object}>,
	only: Bool
}

typedef NTryOptions = {
	all: Bool
}

typedef NChangeCaseOptions = {
	part: Option<{limit: Value}>
}

typedef NBreakOptions = {
	_return: Option<{value: Value}>
}

typedef NThrowOptions = {
	name: Option<{word: Word}>
}

typedef NCatchOptions = {
	name: Option<{word: Value}>
}

typedef NExtendOptions = {
	_case: Bool
}

typedef NBaseOptions = {
	base: Option<{baseValue: Integer}>
}

typedef NToLocalFileOptions = {
	full: Bool
}

typedef NWaitOptions = {
	all: Bool
}

typedef NChecksumOptions = {
	with: Option<{spec: Value}>
}

typedef NNewLineOptions = {
	all:  Bool,
	skip: Option<{size: Integer}>
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
	input:   Option<{_in: Value}>,
	output:  Option<{out: Value}>,
	error:   Option<{err: Value}>
}

typedef NCompressOptions = {
	zlib:    Bool,
	deflate: Bool
}

typedef NDecompressOptions = {
	zlib:    Option<{size: Integer}>,
	deflate: Option<{size: Integer}>
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
	part:    Option<{length: Value}>,
	into:    Option<{dst: Value}>,
	trace:   Option<{callback: Function}>
}

typedef _NativeOptions = {}