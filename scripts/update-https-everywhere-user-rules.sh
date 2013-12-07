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


# Please specify full path to Git binary if you have it installed in a
# directory that isn't present in your PATH environment variable.
declare -r git='git'

# Directory where Firefox stores its user profiles.
declare -r firefoxProfilesDir="$HOME/.mozilla/firefox"


function findHttpsEverywhereDirs()
{
    local -r dir="$1"; shift

    find "$dir" \
        -mindepth 2 -maxdepth 2 \
        -name 'HTTPSEverywhereUserRules' \
        -print0
}


function updateRepositories()
{
    local dir

    while IFS= read -d $'' dir; do
        if [[ -d "$dir/.git" ]]; then
        (
            cd "$dir"
            "$git" pull
        )
        fi
    done
}


function isCommandAvailable()
{
    local -r cmd="$1"; shift

    which "$cmd" 2>&1 > /dev/null
}


function msg()
{
    local line

    for line in "$@"; do
        echo "$line" 1>&2
    done
}


function main()
{
    if ! isCommandAvailable "$git"; then
        msg 'Error: git: Command not found.' \
            '  On Debian Linux please install git-core package.' \
            '  exit(1)' \
        exit 1
    fi

    if [[ ! -d "$firefoxProfilesDir" ]]; then
        msg "Warning: \`$firefoxProfilesDir': Directory doesn't exist." \
            '  Repository update is not possible.' \
            '  exit(0)' \
        exit 0
    fi

    # See https://www.eff.org/https-everywhere/rulesets for details.
    findHttpsEverywhereDirs "$firefoxProfilesDir" \
    | updateRepositories
}

main "$@"

# vim: tabstop=4 shiftwidth=4 expandtab
