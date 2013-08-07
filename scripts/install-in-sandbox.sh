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

DEFAULT_WORKING_DIR='.'
DEFAULT_SANDBOX_DIR='sandbox' # Relative to DEFAULT_WORKING_DIR

printHelp()
{
    cat << EOF
Usage:
  ${0##*/} [-C|-c] [-w WORKING_DIR] [SANDBOX_DIR] [-- CABAL_OPTIONS]
  ${0##*/} {-h|--help}

Options:

-C, --cabal-install
  Use cabal-install for installation.

  Default if cabal-dev is not installed.

-c, --cabal-dev
  Use cabal-dev for installation.

  Default if cabal-dev is installed.

-w WORKING_DIR, --working-dir=WORKING_DIR
  Change working directory to WORKING_DIR before calling cabal-install or
  cabal-dev. This option is useful if you use this script via Ansible to
  prepare the environment.

  Default value is ".".

-p, --modify-path
  Modify \$PATH environment variable to include \$INSTALL_DIR/bin as a first
  component before invoking cabal-install or cabal-dev. However this is not
  done if directory \$INSTALL_DIR/bin doesn't exist. See also --preserve-path
  and --create-bin-dir options.

  Enabled by default.

-P, --preserve-path
  Don't modify \$PATH environment variable before invoking cabal-install or
  cabal-dev. See also --modify-path option.

-d, --create-bin-dir
  Create \$INSTALL_DIR/bin if it doesn't exist prior to invoking cabal-install
  or cabal-dev. If --modify-path is also enabled (default behaviour) then
  \$PATH environment variable will be adapted also.

-h, --help
  Print this help and exit.

SANDBOX_DIR
  Directory where the sandbox directory will be installed. If this directory
  doesn't exist it will be created. If the path starts with '/' it's used as
  is, otherwise "\$WORKING_DIR/\$SANDBOX_DIR" is used. Don't use relative path
  starting with "." or ".." directory, rather use something like
  "\`pwd\`/foo-bar" or "\`pwd\`/../foo-bar".

  Default value is: "\$WORKING_DIR/$DEFAULT_SANDBOX_DIR".

CABAL_OPTIONS
  Options passed down to "cabal install" or "cabal-dev install".
EOF
}

error()
{
    local RC=$1; shift

    echo "ERROR:" "$@" 1>&2
    if [ $RC -eq 1 ]; then
        echo 1>&2
        printHelp 1>&2
    fi
    exit $RC
}

isCommandAvailable()
{
    which "$1" 2>&1 > /dev/null
}

isImplAvailable()
{
    local CMD=''

    case "$1" in
      'cabal-dev') CMD='cabal-dev';;
      'cabal-install') CMD='cabal';;
    esac

    isCommandAvailable "$CMD"
}

getImpl()
{
    if [ -z "$1" ]; then
        for I in 'cabal-dev' 'cabal-install'; do
            if isImplAvailable "$I"; then
                echo "$I"
                return 0
            fi
        done
    elif isImplAvailable "$1"; then
        echo "$1"
        return 0
    fi

    return 1
}

# Convert relative path in to absolute.
canonicalizePath()
{
    readlink -f "$1"
}

# Cabal-install or cabal-dev won't have "$INSTALL_DIR/bin" in their path by
# default. When installing more then one package in to the same sandbox it is
# sometimes useful that the tools installed in previously are available to the
# package being currently installed.
cabalPath()
{
    local MODIFY_PATH="$1"
    local SANDBOX_BIN_DIR="$2"
    local CABAL_USE_PATH="$PATH"

    if [ $MODIFY_PATH -eq 1 ] && [ -d "$SANDBOX_BIN_DIR" ]; then
        CABAL_USE_PATH="$SANDBOX_BIN_DIR:$CABAL_USE_PATH"
    fi

    echo "$CABAL_USE_PATH"
}

cabalInstallMain()
{
    local WD="$1"; shift
    local INSTALL_DIR="$1"; shift
    local MODIFY_PATH="$1"; shift
    local CREATE_BIN_DIR="$1"; shift
    local PACKAGES_CONF=''
    local SANDBOX_BIN_DIR=''

    for CMD in 'ghc' 'ghc-pkg'; do
        if ! isCommandAvailable "$CMD"; then
            error 2 "$CMD" 'not found, this command is required while' \
                ' compiling using cabal-install'
        fi
    done

    # Prepare installation directory structure if some components doesn't
    # exist.
    if [ ! -d "$INSTALL_DIR" ]; then
        mkdir -p "$INSTALL_DIR"
    fi
    INSTALL_DIR="`canonicalizePath "$INSTALL_DIR"`"
    SANDBOX_BIN_DIR="$INSTALL_DIR/bin"

    # See option `--create-bin-dir'.
    if [ $CREATE_BIN_DIR -eq 1 ] && [ ! -d "$SANDBOX_BIN_DIR" ]; then
        mkdir "$SANDBOX_BIN_DIR"
    fi

    # If package DB doesn't exist empty one will be created.
    PACKAGES_CONF="$INSTALL_DIR/packages-`ghc --numeric-version`.conf"
    if [ ! -d "$PACKAGES_CONF" ]; then
        ghc-pkg init "$PACKAGES_CONF"
    fi

    (
        cd "$WD"
        env PATH="`cabalPath "$MODIFY_PATH" "$SANDBOX_BIN_DIR"`" \
            cabal install \
                --prefix="$INSTALL_DIR" \
                --package-db="$PACKAGES_CONF" \
                "$@"
    )
}

cabalDevMain()
{
    local WD="$1"; shift
    local INSTALL_DIR="$1"; shift
    local MODIFY_PATH="$1"; shift
    local CREATE_BIN_DIR="$1"; shift
    local SANDBOX_BIN_DIR=''

    # Prepare installation directory structure if some components doesn't
    # exist. This step is not normally required, but we need it for path
    # canonicalization to work.
    if [ ! -d "$INSTALL_DIR" ]; then
        mkdir -p "$INSTALL_DIR"
    fi
    INSTALL_DIR="`canonicalizePath "$INSTALL_DIR"`"
    SANDBOX_BIN_DIR="$INSTALL_DIR/bin"

    # See option `--create-bin-dir'.
    if [ $CREATE_BIN_DIR -eq 1 ] && [ ! -d "$SANDBOX_BIN_DIR" ]; then
        mkdir "$SANDBOX_BIN_DIR"
    fi

    (
        cd "$WD"
        env PATH="`cabalPath "$MODIFY_PATH" "$SANDBOX_BIN_DIR"`" \
            cabal-dev install \
                --sandbox="$INSTALL_DIR" \
                "$@"
    )
}

# Main ########################################################################

CREATE_BIN_DIR=0
END_OF_OPTIONS=0
FORCE_IMPL=''
MODIFY_PATH=1
while [ $# -gt 0 -a $END_OF_OPTIONS -ne 1 ]; do
    case "$1" in
      '-C'|'--cabal-install')
        FORCE_IMPL='cabal-install'
        ;;
      '-c'|'--cabal-dev')
        FORCE_IMPL='cabal-dev'
        ;;
      '-w'|'--working-dir'|'--working-dir='*)
        if [ "$1" = '-w' -o "$1" = "--working-dir" ]; then
            shift
            WORKING_DIR="$1"
        else
            WORKING_DIR="${1#--working-dir=}"
        fi
        ;;
      '-p'|'--modify-path')
        MODIFY_PATH=1
        ;;
      '-P'|'--preserve-path')
        MODIFY_PATH=0
        ;;
      '-d'|'--create-bin-dir')
        CREATE_BIN_DIR=1
        ;;
      '-h'|'--help'|'-help')
        printHelp
        exit 0
        ;;
      '--')
        END_OF_OPTIONS=1
        ;;
      -*)
        error 1 'Unknown option' "'$1'"
        ;;
      *)
        [ -n "$SANDBOX_DIR" ] && error 1 "SANDBOX_DIR already specified."
        SANDBOX_DIR="$1"
        ;;
    esac
    shift
done

if [ -z "$WORKING_DIR" ]; then
    WORKING_DIR="$DEFAULT_WORKING_DIR"
fi

if [ -z "$SANDBOX_DIR" ]; then
    SANDBOX_DIR="$WORKING_DIR/$DEFAULT_SANDBOX_DIR"
elif [ "`echo "$SANDBOX_DIR" | head -c 1`" != '/' ]; then
    SANDBOX_DIR="$WORKING_DIR/$SANDBOX_DIR"
fi

IMPL="`getImpl "$FORCE_IMPL"`" || {
    if [ -z "$FORCE_IMPL" ]; then
        error 2 "$FORCE_IMPL not found."
    else
        error 2 'Neither cabal-dev nor cabal-install was found.'
    fi
}

case "$IMPL" in
  'cabal-install')
    cabalInstallMain \
        "$WORKING_DIR" "$SANDBOX_DIR" "$MODIFY_PATH" "$CREATE_BIN_DIR" "$@"
    ;;
  'cabal-dev')
    cabalDevMain \
        "$WORKING_DIR" "$SANDBOX_DIR" "$MODIFY_PATH" "$CREATE_BIN_DIR" "$@"
    ;;
  *)
    error 2 'Unknown installation tool' "'$IMPL'," \
        'please consider sending a bug request.'
    ;;
esac

# vim:ts=4:sw=4:expandtab
