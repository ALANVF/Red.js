package types.base;

import haxe.ds.Option;

typedef ARandomOptions = {
	seed:   Bool,
	secure: Bool,
	only:   Bool
}

typedef AFormOptions = {
	?part: {limit: Integer}
}

typedef AMoldOptions = {
	only:  Bool,
	all:   Bool,
	flat:  Bool,
	?part: {limit: Integer}
}

typedef AModifyOptions = {
	_case: Bool
}

typedef ARoundOptions = {
	?to:         {scale: Value},
	even:        Bool,
	down:        Bool,
	halfDown:    Bool,
	floor:       Bool,
	ceiling:     Bool,
	halfCeiling: Bool
}

typedef AAppendOptions = {
	?part: {length: Value},
	only:  Bool,
	?dup:  {count: Integer}
}

typedef AChangeOptions = {
	?part: {range: Value},
	only:  Bool,
	?dup:  {count: _Number}
}

typedef ACopyOptions = {
	?part:  {length: Value},
	deep:   Bool,
	?types: {kind: IDatatype}
}

typedef AFindOptions = {
	?part:   {length: Value},
	only:    Bool,
	_case:   Bool,
	same:    Bool,
	any:     Bool,
	?with:   {wild: String},
	?skip:   {size: Integer},
	last:    Bool,
	reverse: Bool,
	tail:    Bool,
	match:   Bool
}

typedef AInsertOptions = {
	?part: {length: Value},
	only:  Bool,
	?dup:  {count: Integer}
}

typedef AMoveOptions = {
	?part: {length: Integer}
}

typedef APutOptions = {
	_case: Bool
}

typedef ARemoveOptions = {
	?part: {length: Value},
	?key:  {keyArg: Value}
}

typedef AReverseOptions = {
	?part: {length: Value},
	?skip: {size: Integer}
}

typedef ASelectOptions = {
	?part:   {length: Value},
	only:    Bool,
	_case:   Bool,
	same:    Bool,
	any:     Bool,
	?with:   {wild: String},
	?skip:   {size: Integer},
	last:    Bool,
	reverse: Bool
}

typedef ASortOptions = {
	_case:    Bool,
	?skip:    {size: Integer},
	?compare: {comparator: Value},
	?part:    {length: Value},
	all:      Bool,
	reverse:  Bool,
	stable:   Bool
}

typedef ATakeOptions = {
	?part: {length: Value},
	deep:  Bool,
	last:  Bool
}

typedef ATrimOptions = {
	head:  Bool,
	tail:  Bool,
	auto:  Bool,
	lines: Bool,
	all:   Bool,
	?with: {str: Value}
}

typedef AOpenOptions = {
	_new:   Bool,
	read:   Bool,
	write:  Bool,
	seek:   Bool,
	?allow: {access: Block}
}

typedef AReadOptions = {
	?part:  {length: _Number},
	?seek:  {index: _Number},
	binary: Bool,
	lines:  Bool,
	info:   Bool,
	?as:    {encoding: Word}
}

typedef AWriteOptions = {
	binary: Bool,
	lines:  Bool,
	info:   Bool,
	append: Bool,
	?part:  {length: _Number},
	?seek:  {index: _Number},
	?allow: {access: Block},
	?as:    {encoding: Word}
}

typedef _ActionOptions = {}