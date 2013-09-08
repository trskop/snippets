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

# TODO:
#
# * Check MD5/SHA checksum on (normal) download if provided on command line.

function usage()
{
    cat << EOF
Simplified download wrapper script for wget/curl.
    
Usage:

  ${0##*/} [OPTIONS] URL [OUT_FILE]
  ${0##*/} [OPTIONS] {--config=FILE|-c FILE}
  ${0##*/} {-h|--help}

Options:

  --no-checksum

    When downloading file based on specified URL then don't compute checksums.
    In case of download based on configuration file, with checksums specified,
    don't check them after successful download.
EOF
}

function error()
{
    local EXIT_CODE=$1; shift
    local FORMAT=$1; shift

    printf "Error: $FORMAT\n" "$@" 1>&2
    exit $EXIT_CODE
}

function warning()
{
    local FORMAT="$1"; shift

    printf "Warning: $FORMAT\n" "$@" 1>&2
}

function isCommandAvailable()
{
    which "$1" 1>&2 > /dev/null
}

function download()
{
    local URL="$1"
    local OUT_FILE="$2"

    if isCommandAvailable 'wget'; then
        # [ -n "$OUT_FILE" ] && wget -O "$OUT_FILE" "$URL" || wget "$URL"
        wget -O "$OUT_FILE" "$URL"
    elif isCommandAvailable 'curl'; then
        curl "$URL" > "$OUT_FILE"
    fi
}

function mkChecksum()
{
    local HASH="$1"
    local OUT_FILE="$2"
    local COMMAND=''
    local VARIABLE_NAME=''

    case "$HASH" in
      MD5)
        VARIABLE_NAME='MD5SUM'
        COMMAND='md5sum'
        ;;
      SHA1)
        VARIABLE_NAME='SHA1SUM'
        COMMAND='sha1sum'
        ;;
      SHA256)
        VARIABLE_NAME='SHA256SUM'
        COMMAND='sha256sum'
        ;;
    esac

    if isCommandAvailable "$COMMAND"; then
        "$COMMAND" "$OUT_FILE" \
        | sed 's/^\([^ ]\+\) .*$/'"${VARIABLE_NAME}='\1'/"
    else
        warning "%s: Command not found.\n  Can't create %s sum." \
            "$COMMAND" "$HASH"
    fi
}

function logDateAndTime()
{
    local OUT_FILE="$1"

    echo "TIMESTAMP='`date --rfc-3339='seconds'`'" >> "$OUT_FILE"
}

function checkChecksum()
{
    local HASH="$1"
    local CHECKSUM="$2"
    local OUT_FILE="$3"

    if [ -z "$CHECKSUM" ]; then
        return
    fi

    case "$HASH" in
      MD5)
        COMMAND='md5sum'
        ;;
      SHA1)
        COMMAND='sha1sum'
        ;;
      SHA224)
        COMMAND='sha224sum'
        ;;
      SHA256)
        COMMAND='sha256sum'
        ;;
      SHA384)
        COMMAND='sha384sum'
        ;;
      SHA512)
        COMMAND='sha512sum'
        ;;
    esac

    if isCommandAvailable "$COMMAND"; then
        echo "$CHECKSUM  $OUT_FILE" | "$COMMAND" --check -
    else
        warning "%s: Command not found.\n  Can't check %s sum." \
            "$COMMAND" "$HASH"
    fi
}

function normalDownload()
{
    local DO_CHECKSUM="$1"; shift
    local URL="$1"
    local OUT_FILE=''
    local DWL_FILE=''

    if [ $# -eq 2 ]; then
        OUT_FILE="$2"
    else
        OUT_FILE="${URL##*/}"
    fi

    DWL_FILE="$OUT_FILE.download"
    if [ -e "$OUT_FILE" ]; then
        error 1 '%s: File already exists.' "$OUT_FILE"
    elif [ -e "$DWL_FILE" ]; then
        error 1 '%s: File already exists.' "$DWL_FILE"
    fi

    echo URL="'$URL'" > "$DWL_FILE"
    echo OUT_FILE="'$OUT_FILE'" >> "$DWL_FILE"

    download "$URL" "$OUT_FILE"

    if [ "$DO_CHECKSUM" -gt 0 ]; then
        for HASH in 'MD5' 'SHA1' 'SHA256'; do
            mkChecksum "$HASH" "$OUT_FILE" >> "$DWL_FILE"
        done
    fi

    logDateAndTime "$DWL_FILE"
}

function configDownload()
{
    local DO_CHECKSUM="$1"; shift
    local DWL_FILE="$1"

    local URL=''
    local OUT_FILE=''

    local MD5SUM=''
    local SHA1SUM=''
    local SHA224SUM=''
    local SHA256SUM=''
    local SHA384SUM=''
    local SHA512SUM=''

    source "$DWL_FILE"

    if [ -z "$OUT_FILE" ]; then
        OUT_FILE="${URL##*/}"
    fi

    download "$URL" "$OUT_FILE"

    if [ "$DO_CHECKSUM" -gt 0 ]; then
        for HASH in 'SHA1' 'SHA224' 'SHA256' 'SHA384' 'SHA512' 'MD5'; do
            eval "local HASH_VALUE=\"\${${HASH}SUM}\""
            checkChecksum "$HASH" "$HASH_VALUE" "$OUT_FILE"
        done
    fi
}

# Main ########################################################################

if [ $# -eq 0 -o $# -gt 2 ]; then
    usage 1>&2
    exit 1
fi

DO_CHECKSUM=1
case "$1" in
  '-h'|'--help')
     usage
     exit 0
     ;;
  '--no-checksum')
     DO_CHECKSUM=0
     ;;
  '-c')
    if [ $# -ne 2 ]; then
        usage 1>&2
        exit 1
    fi
    configDownload "$DO_CHECKSUM" "$2"
    ;;
  '--config='*)
    configDownload "$DO_CHECKSUM" "${1#--config=}"
    ;;
  *)
    normalDownload "$DO_CHECKSUM" "$@"
    ;;
esac

# vim:ts=4 sw=4 expandtab
