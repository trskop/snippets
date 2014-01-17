# Copyright (c) 2010 - 2014, Peter Trsko <peter.trsko@gmail.com>
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

# https://stackoverflow.com/questions/592620/how-to-check-if-a-program-exists-from-a-bash-script
function haveCommand()
{
    hash "$1" 2> /dev/null
}

# Examples of various values of uname fields can be found on:
#
#   https://en.wikipedia.org/wiki/Uname
function systemName()
{
    local -r sys="$(uname -s)"

    case "$(uname -s)" in
      'MINGW32_NT'*)
        echo 'MinGW'
        ;;
      'CYGWIN_NT'*)
        echo 'Cygwin'
        ;;
      *)
        echo "$sys"
        ;;
    esac
}

if [[ "$(systemName)" == 'MinGW' ]]; then
    function mingwRootDir()
    {
        local -r rootDir="$(cd /; pwd -W)"

        echo "$rootDir"
    }
fi

# vim: tabstop=4 shiftwidth=4 expandtab filetype=sh
