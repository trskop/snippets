#!/bin/bash

# Copyright (c) 2014, Peter Trsko <peter.trsko@gmail.com>
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

# Useful information about ANSI escape sequences can be found on:
#
#   https://en.wikipedia.org/wiki/ANSI_escape_code

#declare -r -a modifiers=(1 2 3 4 5 6 7 8 9)
declare -r -a modifiers=(1 2)
declare -r -i minForegroundColor=30
declare -r -i maxForegroundColor=37
declare -r -i minBackgroundColor=40
declare -r -i maxBackgroundColor=47

function main()
{
    # Sample text, has to be 3 chars long.
    #
    # TODO: It's possible to generalize this to text of arbitrary length.
    local -r text='iAm'

    # String of spaces used to fill out unused space in table cells. It has to
    # be at least 8 characters long.
    #
    # TODO: Calculate it's length from $text size and generate it, but it won't
    # get under 8 characters in any case.
    local -r filling='          '

    # First we will generate arrays of escape sequence attributes for rows and
    # colums. This allows easier debugging and possibly extend it to support
    # 256 colour sequences without a lot of modification to the table printing
    # routine.
    local -a rows=()
    local -a cols=()

    # Create all combinations of modifiers and foreground colors.
    rows=('')   # No modifiers set.
    rows=("${rows[@]}" "${modifier[@]}")
    for modifier in "${modifiers[@]}"; do
        for fgColor in '' `seq $minForegroundColor $maxForegroundColor`; do
            # Empty string above is for no foreground set.
            rows=("${rows[@]}" "${modifier:+$modifier;}$fgColor")
        done
    done

    cols=('')   # Without background set.
    for bgColor in `seq $minBackgroundColor $maxBackgroundColor`; do
        cols=("${cols[@]}" "$bgColor")
    done

    # Print the color table.

    printf '\033[0m'  # Unset all attributes.

    # Header line with background colors.
    printf '%s' "${filling:0:8}"  # Empty box where foreground would be.
    for col in "${cols[@]}"; do
        if [[ -n "$col" ]]; then
            printf '  %s  ' "${col}m"
        else
            # Empty box 2 spaces on the left + 2 spaces on the right + 3
            # maximal size of background definition and also size of sample
            # text.
            printf '%s' "${filling:0:7}"
        fi
    done
    echo    # End of header line with background colors.

    # Table values with used foreground and modifiers printed in the left
    # column.
    for row in "${rows[@]}"; do
        # Print left most column with foreground color and other attributes
        # except background.
        #
        # Filling is computed like this: 6 is maximal size of the box (8 chars)
        # minus two spaces already present in format string - size of the
        # attributes - 1 for 'm' character.
        printf '%s%s  ' "${filling:0:$((6 - ${#row} - 1))}" "${row}m"

        # Print the colored boxes with sample text.
        for col in "${cols[@]}"; do
            # Value of col might be empty string, therefore escape sequence for
            # background specification has to be ignored altogether.
            printf "\033[${row}m${col:+\033[${col}m}  %s  \033[0m" "$text"
        done
        echo    # End of row.
    done
}

main "@"

# vim: tabstop=4 shiftwidth=4 expandtab filetype=sh
