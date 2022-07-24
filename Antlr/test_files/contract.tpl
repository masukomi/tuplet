def deposit: [amount]
	contract: [[amount number?:~]] => boolean?:~
	return true

def print-hello: []
	contract: [] => string?:~
	return "hello"

def x->to-integer: [x]
	contract: [[x or: number?:~ string?:~]] => integer?:~
