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

# Enable colorization of standard commands.
if [[ -x /usr/bin/dircolors ]]; then
    eval "$(dircolors -b)"

    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Wrapper 'colordiff' for standard 'diff' needs to be installed separately.
if haveCommand 'colordiff'; then
    alias diff='colordiff'
elif haveCommand 'grc'; then
    alias diff='grc diff'
fi

# Make destructive operations safer by forcing interactive mode.
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

if haveCommand 'sudo'; then
    alias evil='sudo su -'
elif haveCommand 'su'; then
    # In example Cygwin and Msys doesn't have 'su' command.
    alias evil='su -'
fi

if haveCommand 'apt-get'; then
    alias apt-get='sudo apt-get'
fi

if haveCommand 'ghci'; then
    # Option -ignore-dot-ghci will force ghci to not load settings from
    # ~/.ghc/ghci.conf configuration file.
    alias ghci_='ghci -ignore-dot-ghci -Wall'
fi

if haveCommand 'mplayer'; then
    # Simple way to circumvent Bash completion for mplayer. Useful in cases
    # when trying to look at partially downloaded file that doesn't have the
    # right extension, etc.
    alias mplayer_='mplayer'
fi

# Set terminal title to specified value. Usage: term-title STRING. Tested with
# urxvt and xterm.
alias term-title='printf "\033]2;%s\007"'

# vim: tabstop=4 shiftwidth=4 expandtab filetype=sh
