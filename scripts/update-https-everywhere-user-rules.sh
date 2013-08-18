#!/bin/sh

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
GIT='git'

# Directory where FireFox stores it's user profiles.
FIREFOX_PROFILES_DIR="$HOME/.mozilla/firefox"

if ! which "$GIT" 2>&1 > /dev/null; then
    echo 'Error: git: Command not found.' 1>&2
    echo '  On Debian Linux please install git-core package.' 1>&2
    echo '  exit(1)' 1>&2
    exit 1
fi

if [ ! -d "$FIREFOX_PROFILES_DIR" ]; then
    echo "Warning: \`FIREFOX_PROFILES_DIR': Directory doesn't exist." 1>&2
    echo '  Repository update is not possible.' 1>&2
    echo '  exit(0)' 1>&2
    exit 0
fi

# See https://www.eff.org/https-everywhere/rulesets for details.
ls -d "$FIREFOX_PROFILES_DIR"/*/HTTPSEverywhereUserRules \
| tr '\n' '\0' \
| xargs -0 -n1 sh -c 'if [ -d "$0/.git" ]; then cd $0; "'"$GIT"'" pull; fi'
