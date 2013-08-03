#!/bin/bash

# Script ssh-copy-id(1) is great, but it requires to be able to login to the
# remote host. This script prepares directory and authorized_keys file on the
# server for specified user or current one if not specified.

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

printHelpAndExit()
{
    echo "Usage: ${0##*/} [-h|--help|USERNAME]"
    exit $1
}

msg()
{
    local TYPE="$1"; shift
    case "$TYPE" in
      START)
        local FORMAT="$1"; shift
        printf "$FORMAT... " "$*"
        ;;
      DONE)
        echo 'done.'
        ;;
      NOP)
        echo 'nothing to do.'
        ;;
      FAILED)
        local EXIT_CODE=$1; shift
        echo 'failed with:' "$*"
        exit $EXIT_CODE
        ;;
      ERROR)
        local EXIT_CODE=$1; shift
        echo 'ERROR:' "$*"
        printHelpAndExit $EXIT_CODE
        ;;
      *)
        echo "$*"
        ;;
    esac
}

setPermissions()
{
    local FILE="$1"
    local PERM="$2"
    msg START 'Changing permissions of "%s"' "$FILE"
    if [ `stat -c '%a' "$FILE"` -ne $PERM ]; then
        RSP="`chmod $PERM "$FILE" 2>&1`"
        if [ $? -eq 0 ]; then
           msg DONE
        else
           msg FAILED 1 "$RSP"
        fi 
    else
        msg NOP
    fi
}

setOwnership()
{
    local FILE="$1"
    local OWNERSHIP="$2:`id -ng $2`"
    msg START 'Changing ownership of "%s"' "$FILE"
    if [ `stat -c '%U:%G' "$FILE"` != "$OWNERSHIP" ]; then
        RSP="`chown "$OWNERSHIP" "$FILE" 2>&1`"
        if [ $? -eq 0 ]; then
           msg DONE
        else
           msg FAILED 1 "$RSP"
        fi 
    else
        msg NOP
    fi
}

createDirectory()
{
    local DIR="$1"
    msg START 'Creating directory "%s"' "$DIR"
    if [ -e "$DIR" ]; then
        if ! [ -d "$DIR" ]; then
            msg FAILED 1 "Already exists but it isn't a directory."
        else
            msg NOP
        fi
    else
        RSP="`mkdir "$DIR" 2>&1`"
        if [ $? -eq 0 ]; then
           msg DONE
        else
           msg FAILED 1 "$RSP" 
        fi 
    fi
}

createEmptyFile()
{
    local FILE="$1"
    msg START 'Creating empty "%s"' "$FILE"
    if [ -e "$FILE" ]; then
        if ! [ -f "$FILE" ]; then
            msg FAILED 1 "Already exists but it isn't a regular file."
        else
            msg NOP
        fi
    else
        RSP="`touch "$FILE" 2>&1`"
        if [ $? -eq 0 ]; then
           msg DONE
        else
           msg FAILED 1 "$RSP" 
        fi 
    fi
}

# main ########################################################################

if [ $# -eq 0 ]; then
    TARGET_USER="$USER"
    TARGET_USER_HOME="$HOME"
elif [ "$1" = '-h' -o "$1" = '--help' ]; then
    printHelpAndExit 0
else
    TARGET_USER="$1"
    if [ `id -u 2> /dev/null` -ne 0 ]; then
        msg ERROR 1 'Only root can specify USERNAME.'
    elif ! id "$TARGET_USER" 2>&1 > /dev/null; then
        msg ERROR 1 'No such user' "$TARGET_USER"
    fi
    TARGET_USER_HOME="`eval "echo ~$TARGET_USER"`"
fi

DOT_SSH="$TARGET_USER_HOME/.ssh"
AUTHORIZED_KEYS="$DOT_SSH/authorized_keys"

createDirectory "$DOT_SSH"
setOwnership "$DOT_SSH" "$TARGET_USER"
setPermissions "$DOT_SSH" 700
createEmptyFile "$AUTHORIZED_KEYS"
setOwnership "$AUTHORIZED_KEYS" "$TARGET_USER"
setPermissions "$AUTHORIZED_KEYS" 600
