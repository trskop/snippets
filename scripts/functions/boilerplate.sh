# Copyright (c) 2013, Peter Trsko <peter.trsko@gmail.com>
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#
#     * Neither the name of Peter Trsko nor the names of other
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


# List of functions to be called and its output evaluated at the beginning of
# function definition. Don't use this array directly unless you have to, rather
# register functions using atBeginFunction() function.
declare -a __atBeginFunction=()


# Summary:
#
#   Register function that should be called and its output evaluated at the
#   beginning of function definition.
#
# Usage:
#
#   atBeginFunction FUNCTION_NAME [...]
atBeginFunction()
{
    __atBeginFunction=("${__atBeginFunction[@]}" "$@")
}


# Summary:
#
#   Generate function specific boilerplate code including custom call stack.
#
# Usage:
#
#   beginFunction [FUNCTION_NAME]
#
# Description:
#
#   This function generates script that has to be avaluated as at the begining
# of function definition. As a result we get two local variables __func a
# __call, where first contains function name and the secon array of already
# called functions up to function being currently executed.
#
#   If argument FUNCTION_NAME is provided than it overrides the real name of
# current function.
#
# Example:
#
#     # ---8<---
#     foo()
#     {
#         eval "$(beginFunction)"
#
#         # Function code goes here.
#         :
#     }
#     # ---8<---
beginFunction()
{
    local -r functionName="${1:-\${FUNCNAME[0]}}"

    # Note that __call is in reverse order compared to FUNCNAME.
    cat << EOF
local -r __func="$functionName";
local -r -a __call=("\${__call[@]}" "\$__func");
local -r -i __argc=\$#;
local -r -a __argv=("\$@");
EOF

    for func in "${__atBeginFunction[@]}"; do
        "$func"
    done
}


# Summary:
#
#   Generate call trace string suitable for printing in program messages and
# logs.
#
# Usage:
#
#   calltrace [MESSAGE...]
#
# Description:
#
#   Function concatenates elements of __call variable in to simply
# understandable string, e.g. "main(): foo(): bar(): ". Such string can be used
# as a prefix for various messages either printed to the user or logged by some# logging facility.
#
#   As implied by the previous paragraph, this function requires __call array
# to be properly defined and contain valid value. Note that function calltrace
# doesn't define any local value for it, that would result in having it present
# in its output.
#
#   Any MESSAGE passed to this function will be concatenated to its result, but
# separated from other messages by a space.
# Example:
#
#     # ---8<---
#     echo 'Error:' "$(calltrace)" 'Serious thing happened.' 1>&2
#     # ---8<---
calltrace()
{
    local str=''

    for func in "${__call[@]}"; do
        str="${str:+${str}: }${func}()"
    done

    echo "$str: $@"
}


# Summary:
#
#   Read Bash script and insert function specific boilerplate where it belongs.
#
# Usage:
#
#   insertFunctionBolierplate
#
# Description:
#
#   Function inserts:
#
#     eval "$(beginFunction '<function-name>'"
#
#   at the beginning of each function it encounteres in its input. Only
# exception is a function that is defined in unsupported style:
#
#     function foo() { :; }
insertFunctionBolierplate()
{
    sed -r -e "
/^[ \\t]*(function[ \\t]+)?[0-9a-zA-Z_]+\\(\\)/{
    # Loop through the lines, starting from current line, untill opening curly
    # bracket is found and then insert the boilerplate code after it.
    #
    # The reason for starting from current line, which is the function header,
    # is that it is possible to define function like this:
    #
    #     function foo() {
    #         :
    #     }
    #
    # or even:
    #
    #     function foo() { :; }
    : loop;{
        s/^([^{]*\{)(.*)$/\1 eval \"\$(beginFunction)\"; \2/;t loop-end
        n;b loop
    };: loop-end
}"
}

# vim: tabstop=4 shiftwidth=4 expandtab
