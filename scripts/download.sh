#!/bin/bash

# Copyright (c) 2010 - 2013, Peter Trsko <peter.trsko@gmail.com>
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


# {{{ Messages and Error Handling #############################################

function usage()
{
    local -r progName="${0##*/}"

    local -r -i terminalWidth="$(tput cols || echo 80)"

    fmt --width="$terminalWidth" << EOF
Simplified download wrapper script for wget/curl.

Usage:

  ${progName} [OPTIONS] URL [[-o|--output] OUT_FILE]

  ${progName} [OPTIONS] {--config=FILE|-c FILE}

  ${progName} {-h|--help}

Options:

  -c FILE, --config=FILE

    Download file based on configuration FILE. It has to contain at least one
    entry "URL=<url>".

  -o FILE, --output=FILE

    Use FILE as output file name. If output file name is not specified, then it
    is derived from URL.

  --no-checksum

    When downloading file based on specified URL then don't compute checksums.
    In case of download based on configuration file, with checksums specified,
    don't check them after successful download.

  --checksum

    (Turned on by default.)

    When downloading file based on specified URL then compute checksums.
    In case of download based on configuration file, with checksums specified,
    check them after successful download.

  --check=FILE

    Same as specifying \`--checksum', \`--no-download' and \`--config=FILE'
    together.

  --sha1=CHECKSUM, --sha256=CHECKSUM, --md5=CHECKSUM

    Check if downloaded file matches CHECKSUM when downloaded. These options
    are ignored when downloading file based on configuration file where these
    can be entered.

  --http-proxy=[http://]HOST[:PORT]

    Use specified HTTP proxy server by exporting http_proxy environment
    variable for wget/curl. Warning: this script doesn't check if HOST and PORT
    are syntactically valid values.

  -d, --download

    (Turned on by default.)

    Download file specified by URL or using \`.download' file.

  -n, --no-download

    Don't download, but create \`.download' file or if that is provided then
    just verify checksum(s).

  -h, --help

    Print this help information and exit.
EOF
}

function message()
{
    local -r kind="$1"; shift
    local -r format="$1"; shift

    printf "$kind: $format\n" "$@" 1>&2
}

function error()
{
    local -r exitCode=$1; shift

    message 'Error' "$@"
    exit $exitCode
}

function usageError()
{
    message 'Error' "$@"
    echo 1>&2
    usage 1>&2

    exit 1
}

function fileAlreadyExistsError()
{
    local -r path="$1"; shift

    error 2 '%s: File already exists.' "$path"
}

function fileDoesNotExistOrIsNotReadableError()
{
    local -r path="$1"; shift

    error 2 '%s: File does not exist or is not readable.' "$path"
}

function warning()
{
    message 'Warning' "$@"
}

# }}} Messages and Error Handling #############################################

function isCommandAvailable()
{
    local -r command="$1"; shift

    which "$command" 1>&2 > /dev/null
}

function download()
{
    local -r url="$1"; shift
    local -r outFile="$1"; shift

    if isCommandAvailable 'wget'; then
        # [ -n "$outFile" ] && wget -O "$outFile" "$url" || wget "$url"
        wget -O "$outFile" "$url"
    elif isCommandAvailable 'curl'; then
        curl "$url" > "$outFile"
    fi
}

function mkChecksum()
{
    local -r hash="$1"; shift
    local -r file="$1"; shift
    local command=''
    local variableName=''

    case "$hash" in
      'MD5')
        variableName='MD5SUM'
        command='md5sum'
        ;;
      'SHA1')
        variableName='SHA1SUM'
        command='sha1sum'
        ;;
      'SHA256')
        variableName='SHA256SUM'
        command='sha256sum'
        ;;
      'SHA512')
        variableName='SHA512SUM'
        command='sha512sum'
        ;;
      *)
        warning '%s: Unknown hash algorithm.' "$hash"
        return
        ;;
    esac

    if isCommandAvailable "$command"; then
        "$command" "$file" \
        | sed 's/^\([^ ]\+\) .*$/'"${variableName}='\1'/"
    else
        warning "%s: Command not found.\n  Can't create %s sum." \
            "$command" "$hash"
    fi
}

function logDateAndTime()
{
    local -r file="$1"; shift

    echo "TIMESTAMP='$(date --rfc-3339='seconds')'" >> "$file"
}

function checkChecksum()
{
    local -r hash="$1"; shift
    local -r checksum="$1"; shift
    local -r file="$1"; shift
    local command=''

    if [ -z "$checksum" ]; then
        return
    fi

    case "$hash" in
      'MD5')
        command='md5sum'
        ;;
      'SHA1')
        command='sha1sum'
        ;;
      'SHA224')
        command='sha224sum'
        ;;
      'SHA256')
        command='sha256sum'
        ;;
      'SHA384')
        command='sha384sum'
        ;;
      'SHA512')
        command='sha512sum'
        ;;
    esac

    if isCommandAvailable "$command"; then
        printf "Checking $hash of "
        "$command" --check - <<< "$checksum  $file"
        if (( $? )); then
            exit 2
        fi
    else
        warning "%s: Command not found.\n  Can't check %s sum." \
            "$command" "$hash"
    fi
}

function normalDownload()
{
    local -r -i doDownload="$1"; shift
    local -r -i doChecksum="$1"; shift
    local -r sha1="$1"; shift
    local -r sha256="$1"; shift
    local -r sha512="$1"; shift
    local -r md5="$1"; shift
    local -r url="$1"; shift
    local -r outFile="${1:-${url##*/}}"; shift

    local -r -a knownHashes=('MD5' 'SHA1' 'SHA256' 'SHA512')
    local dwlFile=''
    local checksum=''

    dwlFile="${outFile}.download"
    for file in "$outFile" "$dwlFile"; do
        if [ -e "$file" ]; then
            fileAlreadyExistsError "$file"
        fi
    done

    echo URL="'$url'" > "$dwlFile"
    echo OUT_FILE="'$outFile'" >> "$dwlFile"

    if (( doDownload )); then
        download "$url" "$outFile"
    fi

    for hash in "${knownHashes[@]}"; do
        case "$hash" in
            'MD5') checksum="$md5";;
            'SHA1') checksum="$sha1";;
            'SHA256') checksum="$sha256";;
            'SHA512') checksum="$sha512";;
            *) checksum='';;
        esac

        if [[ -n "$checksum" ]]; then
            checkChecksum "$hash" "$checksum" "$outFile"
        fi
    done

    if (( doChecksum )); then
        for hash in "${knownHashes[@]}"; do
            mkChecksum "$hash" "$outFile" >> "$dwlFile"
        done
    fi

    logDateAndTime "$dwlFile"
}

function configDownload()
{
    local -r -i doDownload="$1"; shift
    local -r -i doChecksum="$1"; shift
    local -r dwlFile="$1"; shift

    local -r knownHashes=('SHA1' 'SHA224' 'SHA256' 'SHA384' 'SHA512' 'MD5')

    local URL=''
    local OUT_FILE=''
    local MD5SUM=''
    local SHA1SUM=''
    local SHA224SUM=''
    local SHA256SUM=''
    local SHA384SUM=''
    local SHA512SUM=''

    if [[ -f "$dwlFile" ]] && [[ -r "$dwlFile" ]]; then
        source "$dwlFile"
    else
        fileDoesNotExistOrIsNotReadableError "$dwlFile"
    fi

    if [ -z "$OUT_FILE" ]; then
        OUT_FILE="${URL##*/}"
    fi

    if (( doDownload )); then
        download "$URL" "$OUT_FILE"
    fi

    if (( doChecksum )); then
        for hash in ${knownHashes[@]}; do
            eval "local hashValue=\"\${${hash}SUM}\""
            checkChecksum "$hash" "$hashValue" "$OUT_FILE"
        done
    fi
}

# {{{ Main ####################################################################

main()
{
    local -i doDownload=1
    local -i doChecksum=1
    local configFile=''
    local url=''
    local outFile=''
    local arg=''
    local sha1=''
    local sha256=''
    local sha512=''
    local md5=''
    local httpProxy=''
    local -a restArgs=()


    while (( $# > 0 )); do
        arg="$1"; shift
        case "$arg" in
          '-h'|'--help')
            usage
            exit 0
            ;;
          '--no-checksum')
            doChecksum=0
            ;;
          '--checksum')
            doChecksum=1
            ;;
          '--check')
            if (( $# == 0 )); then
                usageError "\`$arg': Option is missing an argument."
            fi
            doChecksum=1
            doDownload=0
            configFile="$1"; shift
            ;;
          '--check='*)
            doChecksum=1
            doDownload=0
            configFile="${arg#*=}"
            ;;
          '-c'|'--config')
            if (( $# == 0 )); then
                usageError "\`$arg': Option is missing an argument."
            fi
            configFile="$1"; shift
            ;;
          '--config='*)
            configFile="${arg#*=}"
            ;;
          '--sha1')
            if (( $# == 0 )); then
                usageError "\`$arg': Option is missing an argument."
            fi
            sha1="$1"; shift
            ;;
          '--sha1='*)
            sha1="${arg#*=}"
            ;;
          '--sha256')
            if (( $# == 0 )); then
                usageError "\`$arg': Option is missing an argument."
            fi
            sha256="$1"; shift
            ;;
          '--sha256='*)
            sha256="${arg#*=}"
            ;;
          '--sha512')
            if (( $# == 0 )); then
                usageError "\`$arg': Option is missing an argument."
            fi
            sha512="$1"; shift
            ;;
          '--sha512='*)
            sha512="${arg#*=}"
            ;;
          '--md5')
            if (( $# == 0 )); then
                usageError "\`$arg': Option is missing an argument."
            fi
            md5="$1"; shift
            ;;
          '--md5='*)
            md5="${arg#*=}"
            ;;
          '--http-proxy')
            if (( $# == 0 )); then
                usageError "\`$arg': Option is missing an argument."
            fi
            httpProxy="$1"; shift
            ;;
          '--http-proxy='*)
            httpProxy="${arg#*=}"
            case "$httpProxy" in
                '') ;;
                'http://'*) ;;
                *) httpProxy="http://$httpProxy";;
            esac
            ;;
          '-d'|'--download')
            doDownload=1
            ;;
          '-n'|'--no-download')
            doDownload=0
            ;;
          '-o'|'--output')
            if (( $# == 0 )); then
                usageError "\`$arg': Option is missing an argument."
            fi
            outFile="$1"; shift
            ;;
          '--output='*)
            outFile="${arg#*=}"
            ;;
          *)
            restArgs=("${restArgs[@]}" "$arg")
            ;;
        esac
    done

    if [[ -z "$configFile" ]]; then
        if (( ${#restArgs[@]} == 0 )); then
            usageError 'Too few arguments.'
        elif (( ${#restArgs[@]} > 2 )); then
            usageError 'Too many arguments.'
        elif (( ${#restArgs[@]} == 2 )); then
            if [[ -n "$outFile" ]]; then
                usageError "\`%s': Output file already defined as: \`%s'" \
                    "${restArgs[1]}" "$outFile"
            fi
            outFile="${restArgs[1]}"
        fi
        url="${restArgs[0]}"
    elif (( ${#restArgs[@]} > 0 )); then
        usageError 'Too many arguments.'
    fi

    if [[ -n "$httpProxy" ]]; then
        export http_proxy="$httpProxy"
    fi

    if [[ -n "$configFile" ]]; then
        configDownload \
            "$doDownload" \
            "$doChecksum" \
            "$configFile"
    else
        if (( !doDownload )); then
            # Don't check, since we don't have a file to do that for.
            doChecksum=0
        fi
        normalDownload \
            "$doDownload" \
            "$doChecksum" \
            "$sha1" \
            "$sha256" \
            "$sha512" \
            "$md5" \
            "$url" \
            "$outFile"
    fi
}

main "$@"

# }}} Main ####################################################################

# vim:ts=4 sw=4 expandtab
