#!/usr/bin/env bash

# takes an join string and an array of strings
# ex usage:
#  test_array=("hello" "barry")
#  string-join-with: " " "${test_array[@]}"
function string-join-with:() {
	join_string="$1"
	shift
	arr=("$@")
	result=""
	for index in "${!arr[@]}";
	#for i in "${arr[@]}";
	do
		if [ $index -gt 0 ]; then
			result+="$join_string"
		fi
		result+="${arr[$index]}"
	done
	echo $result
}

function string-join: () {
	arr=("$@")
	string-join-with: "" "${arr[@]}"
}


# Example Usage:
# function use-string-split: () {
# 	local my_arr
# 	test-string-split: my_arr ", " "Paris, France, Europe, Poodle"
# 	#declare -p my_arr;
# 	echo "my_arr: ${my_arr[*]}"
# }
# use-string-split:
#
function string-split: () {
	#= [array_ref split_sequence string_to_split] => nil
	#  populates array_ref with results of split
	#
	#  this would not have been possible without
	#  this brilliant answer on Stack Overflow
	#  https://stackoverflow.com/a/45201229/13973
	#  by bgoldst
	#  alas, macOS / BSD is problematic
	#  so i couldn't use the nul character
	#  and went with the DEL character instead
	#  since it seemed highly unlikely to actually
	#  be in someone's string they were splitting
	local -n arr=$1 
	split_sequence="$2"
	string="$3$2"

	readarray -td $(echo -en '\x7f') arr < <(awk "{gsub(/$split_sequence/, \"$(echo -en '\x7f')\"); print; }" <<<"$string");
	unset 'arr[-1]';
	declare -p arr 2>&1 > /dev/null
}

