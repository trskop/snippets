#!/bin/bash

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

set -e


readonly prefix="$HOME/opt/trskop"
readonly binDir="$HOME/bin"
readonly repoBaseUrl='git@github.com:trskop'
readonly -a gitRepositories=(
    "$repoBaseUrl/snippets.git"
)


function error()
{
    local -r -i exitCode="$1"; shift
    local -r format="$1"; shift

    printf "Error: $format\n" "$@" 1>&2
    exit $exitCode
}


function prepareDir()
{
    local -r dir="$1"; shift

    if [[ ! -d "$dir" ]]; then
        if ! mkdir -p "$dir"; then
            error 1 '%s: %s' "$dir" 'Failed to create directory.'
        fi
    fi
}


function gitClone()
{
    local -r url="$1"; shift
    local -r wd="$1"; shift

    (
        cd "$wd"
        git clone "$url"
    )
}


main()
{
    prepareDir "$prefix"
    prepareDir "$binDir"

    for repo in "${gitRepositories[@]}"; do
        gitClone "$repo" "$prefix"
    done
}


main "$@"

# vim: tabstop=4 shiftwidth=4 expandtab
