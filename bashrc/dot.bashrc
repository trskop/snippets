# ~/.bashrc
#
# This file is executed by bash(1) when invoked as non-login shell, or it might
# also be invoked from ~/.profile or ~/.bash_profile which are execetuted for
# login shells. See bash(1) for details on which is inwoked when and other
# details.

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

# Order in which support scripts are sourced. It is possible to remove/add
# additiona depending on your specific needs.
declare -a bashrc_suffixes=(
    'noninteractive'
    'functions'
    'interactive'
    'aliases'
    'completion'
)
declare rcfile

# Source bashrc components one by one.
for sfx in functions "${bashrc_suffixes[@]}"; do
    rcfile="$HOME/.bash_${sfx}"

    [[ -f "$rcfile" ]] && [[ -r "$rcfile" ]] && . "$rcfile"

    # If not running interactively, don't do anything else.
    [[ "${sfx}" == 'noninteractive' ]] && [[ -z "$PS1" ]] && break
done

# Cleanup global variables to prevent global namespace polution.
unset -v rcfile
unset -v bashrc_suffixes

# vim: tabstop=4 shiftwidth=4 expandtab filetype=sh
