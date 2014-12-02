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

declare -r version='0.1.0.0'

# {{{ Messages and Error Handling #############################################

usage()
{
    local -r -i terminalWidth="$(tput cols || echo 80)"

    printVersion 0

    fmt --width="$terminalWidth" << __END_OF_USAGE__

Script for generating shell archives/installers from unpack/install script and
attachment file which may be a binary, archive, etc.

Usage:

  ${progName} [-a FILE|--attachment-name=FILE] [-o FILE|--output=FILE]
  {-s FILE|--script=FILE} {FILE|-}

  ${progName} {-h|--help|-V|--version|--numeric-version}

Options:

  -s FILE, --script=FILE

    Insert this shell script as in to shell archive and run its doInstall
    function for extracted attachment.

  -o FILE, --output=FILE

    Store output (created shell archive) in to this FILE.

  -a FILE, --attachment-name=FILE

    File name that shell archive will use for storing its attachment after its
    extraction from its body.

  -V, --version

    Print version information and extit.

  --numeric-version

    Print numeric version information and extit.

  -h, --help

    Print this help and exit.
__END_OF_USAGE__
}

printVersion()
{
    local -r -i numericVersion=$1; shift

    if (( numericVersion )); then
        echo "$version"
    else
        echo "$progName $version"
    fi
}

error()
{
    local -r exitCode="$1"; shift
    local -r format="$1"; shift

    printf "$progName: Error: $format\n" "$@"

    if [[ "$exitCode" != '-' ]]; then
        exit "$exitCode"
    fi
}

quote()
{
    printf "\`%s'" "$1"
}

# }}} Messages and Error Handling #############################################

# {{{ Generate Shell Archive/Installer ########################################

_sha1sum()
{
    local -r file="$1"

    sha1sum "$file" | sed --posix -r 's/^(.{40}).*$/\1/'
}

sharHeader()
{
    local -r scriptFile="$1"; shift
    local -r attachment="$1"; shift
    local -r sha1="$1"; shift

    cat << __END_OF_SHAR_HEADER_PART_1__
#!/bin/bash

# This file was generated using ${progName} ${version}.

set -e

declare -r attachmentName='$attachmentName'
declare -r attachmentSha1='$sha1'

checkSha1()
{
    local -r sha1="\$1"; shift
    local -r file="\$1"; shift

    printf '%s  %s\\n' "\$sha1" "\$file" | sha1sum -c - --status
}

__END_OF_SHAR_HEADER_PART_1__

cat "$scriptFile"

    cat << __END_OF_SHAR_HEADER_PART_2__
main()
{
    local -r sharFile="\$1"; shift
    local -r progName="\${sharFile##*/}"

    local -r tempDir="\$(mktemp --tmpdir --directory 'shar.XXXXXXXXXX')"
    if [[ -z "\$tempDir" ]]; then
        echo "\${progName}: Unable to create temporary directory." 1>&2
        exit 1
    fi
    trap "rm -fr -- '\$tempDir'" EXIT

    sed '1,/^__EOF__/d' "\$sharFile" > "\$tempDir/\$attachmentName"
    if ! checkSha1 "\$attachmentSha1" "\$tempDir/\$attachmentName"; then
        echo "\${progName}: Archive checksum doesn't match." 1>&2
        exit 1
    fi

    doInstall "\$tempDir" "\$attachmentName" "\$@"
}

main "\$0" "\$@"
exit 0
__EOF__
__END_OF_SHAR_HEADER_PART_2__
}

generateShar()
{
    local -r scriptFile="$1"; shift
    local -r attachmentFile="$1"; shift
    local -r attachmentName="$1"; shift

    sharHeader "$scriptFile" "$attachmentName" "$(_sha1sum "$attachmentFile")"
    cat "$attachmentFile"
}

# {{{ Generate Shell Archive/Installer ########################################

# {{{ Input/output Handling ###################################################

declare -a temporaryFiles=()
_cleanup()
{
    if (( ${#temporaryFiles[@]} )); then
        rm "${temporaryFiles[@]}"
    fi
}

getInput()
{
    local -r -i rawFilename=$1; shift
    local -r input="$1"; shift

    if (( rawFilename )) || [[ "$input" != '-' ]]; then
        echo "$input"
    else
        local -r tempFile="$(mktemp --tmpdir 'mkshar-input.XXXXXXXXXX')"
        if [[ -z "$tempFile" ]]; then
            error 2 'Unable to create temporary file'
        fi
        temporaryFiles=("${temporaryFiles[@]}" "$tempFile")
        cat > "$tempFile"
        echo "$tempFile"
    fi
}

writeOutput()
{
    local -r output="$1"; shift

    case "$output" in
        '-')
            cat
            ;;
        *)
            cat > "$output"
            ;;
    esac
}

# }}} Input/output Handling ###################################################

main()
{
    local progName="$1"; shift

    local attachment=''
    local attachmentName=''
    local output=''
    local scriptFile=''
    local -i rawFilename=0

    local arg=''
    while (( $# > 0 )); do
        arg="$1"; shift
        case "$arg" in
          -h|--help)
            usage
            exit 0
            ;;
          -V|--version)
            printVersion 0
            exit 0
            ;;
          --numeric-version)
            printVersion 1
            exit 0
            ;;
          --script=*)
            scriptFile="${arg#*=}"
            ;;
          -i)
            if (( $# == 0 )); then
                error 1 '%s: Missing argument' "$(quote "$arg")"
            fi
            scriptFile="$1"; shift
            ;;
          --attachment-name=*)
            attachmentName="${arg#*=}"

            # Only last component (file name) is used, because shell archive
            # can not handle directory structure.
            attachmentName="${attachmentName##*/}"
            ;;
          --output=*)
            output="${arg#*=}"
            ;;
          -o)
            if (( $# == 0 )); then
                error 1 '%s: Missing argument' "$(quote "$arg")"
            fi
            output="$1"; shift
            ;;
          '-')
            if [[ -n "$attachment" ]]; then
                error 1 '%s: Too many arguments' "$(quote "$arg")"
            fi
            attachment="$arg"
              ;;
          '--')
            if (( $# == 1 )); then
                attachment="$1"
            elif (( $# > 1 )); then
                error 1 '%s: Too many arguments' "$(quote "$2")"
            else # (( $# == 0 ))
                error 1 'Too few arguments'
            fi
            rawFilename=1
            ;;
          -*)
            error 1 '%s: Unknown option' "$(quote "$arg")"
            ;;
          *)
            if [[ -n "$attachment" ]]; then
                error 1 '%s: Too many arguments' "$(quote "$arg")"
            fi
            attachment="$arg"
            ;;
        esac
    done

    # TODO: Think of a good default action.
    if [[ -z "$scriptFile" ]]; then
        error 1 '%s: Option has to be specified' "$(quote '--script')"
    fi

    if [[ -z "$attachment" ]]; then
        error 1 'Too few arguments'
    fi

    trap "_cleanup" EXIT
    {
        local -r attachmentFile="$(getInput $rawFilename "$attachment")"

        if [[ -z "$attachmentName" ]]; then
            if [[ "$attachment" != '-' ]]; then
                attachmentName='attachment'
            else
                attachmentName="${attachmentFile##*/}"
            fi
        fi

        generateShar "$scriptFile" "$attachmentFile" "$attachmentName"
    } | writeOutput "${output:--}"
}

main "${0##*/}" "$@"
