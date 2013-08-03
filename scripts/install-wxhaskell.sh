#!/bin/bash

# Script for installing wxWidgets 2.9.5 and wxHaskell from Git repository.
#
# Tested with wxHaskell version 0.90.1.0 commit
# 03950cac597c5f99442281f46e57e32e61bea328.
#
# On Debian/Ubuntu install following:
#
#   $ apt-get install haskell-platform c2hs
#   $ apt-get install build-essential
#   $ apt-get install libglu-dev libgtk2.0-dev
#
#
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

WX_WIDGETS_URL='http://downloads.sourceforge.net/project/wxwindows/2.9.5/wxWidgets-2.9.5.tar.bz2'
WX_HASKELL_URL='https://github.com/wxHaskell/wxHaskell.git'

WX_WIDGETS_FILE="`basename "$WX_WIDGETS_URL"`"
WX_WIDGETS_DIR="`basename "$WX_WIDGETS_URL" '.tar.bz2'`"
WX_WIDGETS_BUILD_DIR='wxWidgets-build'
WX_WIDGETS_INSTALL_DIR='wxWidgets-install'

WX_HASKELL_DIR="`basename "$WX_HASKELL_URL" '.git'`"

ROOT_DIR="`pwd`"


# Build wxWidgets #############################################################

if [ ! -e "$WX_WIDGETS_FILE" ]; then
    wget "$WX_WIDGETS_URL"
fi

if [ ! -e "$WX_WIDGETS_DIR" ]; then
    tar xjf "$WX_WIDGETS_FILE"
fi

for D in "$WX_WIDGETS_BUILD_DIR" "$WX_WIDGETS_INSTALL_DIR"; do
    if [ ! -e "$D" ]; then
        mkdir "$D"
    fi
done

# List of configure options was taken from
# https://github.com/wxHaskell/wxHaskell/blob/master/install.txt
if [ ! -e "$WX_WIDGETS_BUILD_DIR/guard-configure" ]; then
    (
        cd "$WX_WIDGETS_BUILD_DIR"
        ../$WX_WIDGETS_DIR/configure \
            --enable-unicode \
            --disable-debug \
            --prefix="$ROOT_DIR/$WX_WIDGETS_INSTALL_DIR" \
            --enable-stc \
            --enable-aui \
            --enable-propgrid \
            --enable-xrc \
            --enable-ribbon \
            --enable-richtext \
            --with-opengl \
        && touch "$WX_WIDGETS_BUILD_DIR/guard-configure"
    )
fi

if [ ! -e "$WX_WIDGETS_BUILD_DIR/guard-build" ]; then
    (
        cd "$WX_WIDGETS_BUILD_DIR"
        make \
        && touch "$WX_WIDGETS_BUILD_DIR/guard-build"
    )
fi

if [ ! -e "$WX_WIDGETS_BUILD_DIR/guard-install" ]; then
    (
        cd "$WX_WIDGETS_BUILD_DIR"
        make install \
        && touch "$WX_WIDGETS_BUILD_DIR/guard-install"
    )
fi


# Build wxHaskell #############################################################

if [ ! -e "$WX_HASKELL_DIR" ]; then
    git clone "$WX_HASKELL_URL"
fi

# Packages are in order of dependency.
for PKG in 'wxdirect' 'wxc' 'wxcore' 'wx'; do
    PKG_GUARD="./cabal-dev/guard-$PKG"
    if [ ! -e "$PKG_GUARD" ]; then
        env PATH="$PATH:`pwd`/$WX_WIDGETS_INSTALL_DIR/bin:`pwd`/cabal-dev/bin" \
            LD_LIBRARY_PATH="`pwd`/$WX_WIDGETS_INSTALL_DIR/lib" \
            cabal-dev install "./$WX_HASKELL_DIR/$PKG" \
        && touch "$PKG_GUARD"
    fi
done

HADDOCK_GUARD_PREFIX="$ROOT_DIR/cabal-dev/guard-haddock-"
HADDOCK_OPTIONS=''
for PKG in 'wxdirect' 'wxcore' 'wx'; do
    (
        cd "$ROOT_DIR/$WX_HASKELL_DIR/$PKG"
        [ ! -e "${HADDOCK_GUARD_PREFIX}${PKG}" ] \
        && cabal haddock \
            --hyperlink-source \
            ${HADDOCK_OPTIONS:+--haddock-options="$HADDOCK_OPTIONS"} \
        && touch "${HADDOCK_GUARD_PREFIX}${PKG}"
    )
    HADDOCK_OPTIONS="${HADDOCK_OPTIONS:+$HADDOCK_OPTIONS }--read-interface=../$PKG/dist/doc/html/$PKG/${PKG}.haddock"
done
