#!/usr/bin/env bash

# bash function that executes whatever is passed
# to it and captures STDERR, STDOUT, and the Exit code


# takes a string to execute,
# redirects STDERR to STDOUT,
# returns the string result
function shell(){
    "$1" 2>&1
}
function detailed_shell(){
    # requires bash >= 4.3
    # found here https://stackoverflow.com/a/18086548/13973
    # and then combined with https://stackoverflow.com/a/49971213/13973
    execute_this="$1"
    # echo "execute_this: $execute_this"
    local -n stdout=$2
    local -n stderr=$3
    local -n ret=$4
    unset t_std t_err t_ret
    eval "$( $execute_this  \
            2> >(t_err=$(cat); typeset -p t_err) \
            > >( t_std=$(cat);
                 typeset -p t_std);
               t_ret=$?; typeset -p t_ret )"
    stdout=$t_std
    stderr=$t_err
    ret=$t_ret

    # echo "contents in shell()"
    # echo "t_std: ${t_std[*]}"
    # echo "t_err: ${t_err[*]}"
    # echo "t_ret: $t_ret"

}

function call_shell() {
    execute_this="$1"
    local stdout_arr
    local stderr_arr
    local exit_code

    detailed_shell "$execute_this"  stdout_arr stderr_arr exit_code

    echo "stdout_arr: ${stdout_arr[*]}"
    echo "stderr_arr: ${stderr_arr[*]}"
    echo "exit_code: $exit_code"
}

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
multi_output_path=$SCRIPT_DIR/multi_output.sh

echo "calling detailed_shell"
call_shell "$multi_output_path"

echo ""
echo "calling shell"
shell "$multi_output_path"
