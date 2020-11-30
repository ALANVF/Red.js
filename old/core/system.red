Red []

'comment [
system/script: make object! [
	title: none
	header: none
	parent: none
	path: none
	args: none
]

system/standard: make object! [
	header: make object! [
		title: none
		name: none
		type: none
		version: none
		date: none
		file: none
		author: none
		needs: none
	]
	error: make object! [
		code: none
		type: none
		id: none
		arg1: none
		arg2: none
		arg3: none
		near: none
		where: none
		stack: none
	]
	file-info: make object! [
		name: none
		size: none
		date: none
		type: none
	]
]
]