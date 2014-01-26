#!/bin/bash

# Copyright (c) 2013, 2014, Peter Trsko <peter.trsko@gmail.com>
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


readonly prefix="$HOME/opt"

readonly -a prepareDirectories=(
    "$prefix"
    "$prefix/trskop"
    "$HOME/bin"
    "$HOME/man"
    "$HOME/man/man1"
    "$HOME/man/man5"
    "$HOME/.vim"
    "$HOME/.vim/colors"
)
readonly repoBaseUrl='git@github.com:'
#readonly repoBaseUrl='https://github.com/'
readonly -A gitRepositories=(
    ["${repoBaseUrl}trskop/snippets.git"]='github.com/trskop/snippets'
)
readonly -A gitRepositoryHooks=(
    ["${repoBaseUrl}trskop/snippets.git"]='snippetsHook'
)

function snippetsHook()
{
    local -r -a scripts=(
         'download.sh'
         'update-https-everywhere-user-rules.sh'
         'xpdf-compat.sh'
    )

    # Compatibility symbolic link.
    mkSymbolicLink \
        "$prefix/trskop" \
        'snippets' \
        '../github.com/trskop/snippets/'

    mkSymbolicLink \
        "$HOME" \
        '.bashrc' \
        'opt/github.com/trskop/snippets/bashrc/dot.bashrc'

    for script in "${scripts[@]}"; do
        mkSymbolicLink \
            "$HOME/bin" \
            "${script%.sh}" \
            "../opt/github.com/trskop/snippets/scripts/$script"
    done
}

# {{{ Framework ###############################################################

function error()
{
    local -r -i exitCode="$1"; shift
    local -r format="$1"; shift

    printf "Error: $format\n" "$@" 1>&2
    exit $exitCode
}

function info()
{
    if (( verbosity <= 1 )); then
        return;
    fi

    local -r format="$1"; shift

    printf "Info: $format\n" "$@"
}

function echoAndDo()
{
    echo "$@"
    "$@"
}

runHook()
{
    local -r url="$1"; shift

    local -r hook="${gitRepositoryHooks[$url]}"

    if [[ -n "$hook" ]]; then
        info '%s: %s' "$url" \
            'Running repository hook...'
        if "$hook"; then
            info '%s: %s' "$url" \
                'Repository hook terminated successfully.'
        else
            error 1 '%s: %s' "$url" \
                'Repository hook terminated with failure.'
        fi
    fi
}

function prepareDir()
{
    local -r dir="$1"; shift

    if [[ ! -d "$dir" ]]; then
        if ! "${_mkdir[@]}" -p "$dir"; then
            error 1 '%s: %s' "$dir" \
                'Failed to create directory.'
        fi
        info '%s: %s' "$dir" \
            'Directory created successfully.'
    else
        info '%s: %s' "$dir" \
            'Directory already exist.'
    fi
}

function gitClone()
{
    local -r url="$1"; shift
    local -r dir="${1%/}"; shift # Removing trainilng '/'

    local -r wd="${dir%/*}"
    local -r repoDir="${dir##*/}"

    (
        "${_cd[@]}" "$wd"

        if [[ -e "$repoDir" ]]; then
            if [[ -d "$repoDir/.git" ]]; then
                info '%s: %s' "$url" \
                    'Repository already cloned.'
            else
                error 1 '%s: %s: %s' "$url" "$dir" \
                    'Target for repository already exists.'
            fi
        else
            if "${_git[@]}" clone "$url" "$repoDir"; then
                info '%s: %s' "$url" \
                    'Repository successfully cloned.'
            else
                error 1 '%s: %s' "$url" \
                    'Repository cloning terminated with failure.'
            fi
        fi
    )
}

mkSymbolicLink()
{
    local -r wd="$1"; shift
    local -r link="$1"; shift
    local -r dest="$1"; shift

    local backup=

    (
        "${_cd[@]}" "$wd"

        if [[ -L "$link" ]]; then
            # Remove if it's just a link since we aren't loosing any
            # information.
            info '%s: %s' "$link" \
                'Removing old link before creating new one.'
            "${_rm[@]}" "$link"
        elif [[ -e "$link" ]]; then
            backup="${link}~"
            if [[ -e "${link}~" ]]; then
                backup="${link}-$(date +%Y-%m-%d-%H%M%S)~"
            fi
            info '%s -> %s: %s' "$link" "$backup" \
                'Backing up original file before creating link.'
            "${_mv[@]}" "$link" "$backup"
        fi
        "${_ln[@]}" -s "$dest" "$link"
        info '%s -> %s: %s' "$link" "$dest" \
            'Symbolic link created.'
    )
}

main()
{
    local -i dryRun=0
    local -i verbosity=1

    local arg=
    while (( $# > 0 )); do
        arg="$1"; shift
        case "$arg" in
          '--dry-run')
            dryRun=1
            ;;
          '--verbose')
            verbosity=2
            ;;
          '--quiet')
            verbosity=0
            ;;
          *)
            ;;
        esac
    done

    local _mkdir=('mkdir')
    local _cd=('cd')
    local _rm=('rm')
    local _mv=('mv')
    local _ln=('ln')
    local _git=('git')
    if (( dryRun )); then
        _mkdir=('echo' "${_mkdir[@]}")
        _cd=('echo' "${_cd[@]}")
        _rm=('echo' "${_rm[@]}")
        _mv=('echo' "${_mv[@]}")
        _ln=('echo' "${_ln[@]}")
        _git=('echo' "${_git[@]}")
    elif (( verbosity > 1 )); then
        # When dryRun is set and verbosity is > 1, then this modification is
        # not needed, since it would contradict dryRun.
        _mkdir=('echoAndDo' "${_mkdir[@]}")
        _cd=('echoAndDo' "${_cd[@]}")
        _rm=('echoAndDo' "${_rm[@]}")
        _mv=('echoAndDo' "${_mv[@]}")
        _ln=('echoAndDo' "${_ln[@]}")
        _git=('echoAndDo' "${_git[@]}")
    fi

    for dir in "${prepareDirectories[@]}"; do
        prepareDir "$dir"
    done

    local repoDir=
    (
        "${_cd[@]}" "$prefix"

        for url in "${!gitRepositories[@]}"; do
            repoDir="${gitRepositories[$url]}"
            prepareDir "${repoDir%/*}"
            gitClone "$url" "$repoDir"
            runHook "$url"
        done
    )
}

main "$@"

# }}} Framework ###############################################################

# vim: tabstop=4 shiftwidth=4 expandtab
