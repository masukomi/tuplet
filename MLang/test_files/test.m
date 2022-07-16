{a => "dictionary" # comment
	"spanning" => 3
	lines => yo} # comment
["a" "list"
	"that spans lines" ]
"a string
	that spans lines"
##
		multiline comment line 1
			indented multiline comment line 2
##

def foo: [arg1 arg2]
	bar: arg1 arg2
	baz: arg2
	beedle:

def many-args: [foo bar*]
	and: bar

def maybe: [x]
	if: and: x true
		"yup" # trailing comment
		"nope"
		# yup and nope are args of if:

def hello-person: [first_name
	[last_name "smith"]]
	println: concat: "Hello " first_name last_name
	# ^^ function call <- function call args
def variadic: [foo
				bar*]
	"variadic yo"

# a comment line
var: @GLOBAL_X "GLOBAL_X"
true
false
