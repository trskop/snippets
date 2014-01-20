#!/bin/bash

# Compatibility wrapper that provides xpdf-like command line interface for
# other PDF viewers.
#
# If there is no xpdf on your system then it might be a good idea to put this
# script somewhere in to your PATH and create alias for it:
#
#  alias xpdf='xpdf-compat'

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


function usage()
{
    local -r progName="${0##*/}"

    local -r -i terminalWidth="$(tput cols || echo 80)"

    fmt --width="$terminalWidth" << EOF
Compatibility wrapper that provides xpdf-like command line interface for other
PDF viewers.

Usage:

  ${progName} [OPTIONS] [PDF_FILE [PAGE_NUMBER|+NAMED_DESTINATION]]

Options:

  -fullscreen

    Open PDF viewer in fullscreen mode if it supports it.

  -h, -?, [-]-help

    Print this help information and exit. Not passed down to PDF viewer.

  -V, [-]-verbose

    This script will print what it's doing. Not passed down to PDF viewer.

Currently supported PDF viewers are Evince and gv.
EOF
}

function error()
{
    local -r -i exitCode="$1"; shift
    local -r format="$1"; shift

    printf "Error: $format\n" "$@" 1>&2
    exit $exitCode
}

function info()
{
    if (( beVerbose )); then
        echo 'Info:' "$@"
    fi
}

function haveCommand()
{
    hash "$1" >& /dev/null
}

function main()
{
    local -a -r knownCommands=(
        'evince'
        'gv'
    )
    local -a evinceOptions=()
    local -a gvOptions=()

    local -i haveFile=0
    local -i havePosition=0
    local -i beVerbose=0
    local arg=
    while (( $# > 0 )); do
        arg="$1"; shift
        case "$arg" in
          '-h'|'-?'|'-help'|'--help')
            # This option is not passed down.
            usage
            exit 0
            ;;
          '-fullscreen')
            evinceOptions=("${evinceOptions[@]}" '--fullscreen')
            gvOptions=("${gvOptions[@]}" '--fullscreen')
            ;;
          '-V'|'-verbose'|'--verbose')
            # This option is not passed down.
            beVerbose=1
            ;;
          -*)
            error 1 '%s: %s' "$arg" 'Unknown option.'
            ;;
          *)
            if (( haveFile && havePosition )); then
                error 1 '%s: %s' "$arg" 'Too many arguments.'
            fi

            if (( ! haveFile )); then
                haveFile=1
                evinceOptions=("${evinceOptions[@]}" "$arg")
                gvOptions=("${gvOptions[@]}" "$arg")
            else
                havePosition=1
                case "$arg" in
                  +*)
                    evinceOptions=(
                        "${evinceOptions[@]}"
                        "--page-label=${arg#+}"
                    )
                    gvOptions=(
                        "${gvOptions[@]}"
                        "--page=${arg#+}"
                    )
                    ;;
                  *)
                    if grep -q -E '^[0-9]+$' <<< "$arg"; then
                        evinceOptions=(
                            "${evinceOptions[@]}"
                            "--page-index=$arg"
                        )
                        gvOptions=(
                            "${gvOptions[@]}"
                            "--page=$arg"
                        )
                    else
                        error 1 '%s: %s' "$arg" 'Not a page number.'
                    fi
                    ;;
                esac
            fi
            ;;
        esac
    done

    for command in "${knownCommands[@]}"; do
        info "${command}:" 'Checking for availability.'
        if haveCommand "$command"; then
            eval "local -r -a options=(\"\${${command}Options[@]}\")"

            info "Executing:" "$command" "${options[@]}"
            exec "$command" "${options[@]}" >& /dev/null
        fi
    done

    error 2 'No known implementation available.'
}

main "$@"

# vim: tabstop=4 shiftwidth=4 expandtab filetype=sh
