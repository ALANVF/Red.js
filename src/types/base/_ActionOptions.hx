package types.base;

import haxe.ds.Option;

typedef ARandomOptions = {
	seed:   Bool,
	secure: Bool,
	only:   Bool
}

typedef AFormOptions = {
	part: Option<{limit: Integer}>
}

typedef AMoldOptions = {
	only: Bool,
	all:  Bool,
	flat: Bool,
	part: Option<{limit: Integer}>
}

typedef AModifyOptions = {
	_case: Bool
}

typedef ARoundOptions = {
	to:          Option<{scale: Value}>,
	even:        Bool,
	down:        Bool,
	halfDown:    Bool,
	floor:       Bool,
	ceiling:     Bool,
	halfCeiling: Bool
}

typedef AAppendOptions = {
	part: Option<{length: Value}>,
	only: Bool,
	dup:  Option<{count: Integer}>
}

typedef AChangeOptions = {
	part: Option<{range: Value}>,
	only: Bool,
	dup:  Option<{count: _Number}>
}

typedef ACopyOptions = {
	part:  Option<{length: Value}>,
	deep:  Bool,
	types: Option<{kind: IDatatype}>
}

typedef AFindOptions = {
	part:    Option<{length: Value}>,
	only:    Bool,
	_case:   Bool,
	same:    Bool,
	any:     Bool,
	with:    Option<{wild: String}>,
	skip:    Option<{size: Integer}>,
	last:    Bool,
	reverse: Bool,
	tail:    Bool,
	match:   Bool
}

typedef AInsertOptions = {
	part: Option<{length: Value}>,
	only: Bool,
	dup:  Option<{count: Integer}>
}

typedef AMoveOptions = {
	part: Option<{length: Integer}>
}

typedef APutOptions = {
	_case: Bool
}

typedef ARemoveOptions = {
	part: Option<{length: Value}>,
	key:  Option<{keyArg: Value}>
}

typedef AReverseOptions = {
	part: Option<{length: Value}>,
	skip: Option<{size: Integer}>
}

typedef ASelectOptions = {
	part:    Option<{length: Value}>,
	only:    Bool,
	_case:   Bool,
	same:    Bool,
	any:     Bool,
	with:    Option<{wild: String}>,
	skip:    Option<{size: Integer}>,
	last:    Bool,
	reverse: Bool
}

typedef ASortOptions = {
	_case:   Bool,
	skip:    Option<{size: Integer}>,
	compare: Option<{comparator: Value}>,
	part:    Option<{length: Value}>,
	all:     Bool,
	reverse: Bool,
	stable:  Bool
}

typedef ATakeOptions = {
	part: Option<{length: Value}>,
	deep: Bool,
	last: Bool
}

typedef ATrimOptions = {
	head:  Bool,
	tail:  Bool,
	auto:  Bool,
	lines: Bool,
	all:   Bool,
	with:  Option<{str: Value}>
}

typedef AOpenOptions = {
	_new:  Bool,
	read:  Bool,
	write: Bool,
	seek:  Bool,
	allow: Option<{access: Block}>
}

typedef AReadOptions = {
	part:   Option<{length: _Number}>,
	seek:   Option<{index: _Number}>,
	binary: Bool,
	lines:  Bool,
	info:   Bool,
	as:     Option<{encoding: Word}>
}

typedef AWriteOptions = {
	binary: Bool,
	lines:  Bool,
	info:   Bool,
	append: Bool,
	part:   Option<{length: _Number}>,
	seek:   Option<{index: _Number}>,
	allow:  Option<{access: Block}>,
	as:     Option<{encoding: Word}>
}

typedef _ActionOptions = {}