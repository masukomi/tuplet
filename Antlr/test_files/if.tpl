var: a_list [1 2 3]
if: >: size: a_list
		2
	println: "big list"
	println: "small list"
	return: true

# should convert to
(if (> (size a_list) 2)
	(println "big list")
	(println "small list"))

# or
if: >:
		<size: a_list # comment foo
			> # comment
		2
	println: "big list"
	println: "small list"
	return: true

# or
if: <>:
		<size: a_list # comment foo
			> # comment
		2>
	println: "big list"
	println: "small list"
	return: true

# should convert to
(if (> (size a_list # comment foo
		) # comment
		2)
	(println "big list")
	(println "small list"))
