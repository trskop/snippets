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


# Find all files that should be sourced. Separating this from the actual
# sourcing allows us to further limit side effects, like variable overwrite
# etc.
function __dot_bashrc_rcfiles_for_sourcing()
{
    # Order in which support scripts are sourced. It is possible to remove/add
    # additiona depending on your specific needs.
    #
    # Item named 'noninteractive' is a boundary, everything before including
    # it is sourced for non-interactive shell.
    local -r -a bashrc_suffixes=(
        'noninteractive'
        'functions'
        'interactive'
        'aliases'
        'completion'
    )

    # If ~/.bashrc is a symlink, then it will look for scripts dot.bash_${sfx}
    # in the directory where that link points to. This allows to use both, the
    # repository scripts and user's custom scripts.
    if [[ -L "$HOME/.bashrc" ]]; then
        local -r repo_dir="$(dirname "`readlink -m "$HOME/.bashrc"`")"
    else
        local -r repo_dir=''
    fi

    # Make list of files that should be sourced.
    local rcfile
    local repo_rcfile
    for sfx in "${bashrc_suffixes[@]}"; do
        rcfile="$HOME/.bash_${sfx}"

        if [[ -n "$repo_dir" ]]; then
            repo_rcfile="$repo_dir/dot.bash_${sfx}"

            # Don't include ~/.bash_${sfx} if it's a link to the
            # "$repo_rcfile", that would cause it to be included twice.
            [[ -L "$rcfile" && "`readlink -m "$rcfile"`" == "$repo_rcfile" ]] \
                && rcfile=''
        else
            repo_rcfile=''
        fi

        for file in "$repo_rcfile" "$rcfile"; do
            [[ -n "$file" && -f "$file" && -r "$file" ]] \
                && printf '%q\n' "$file"
        done

        # If not running interactively, don't do anything else.
        [[ "${sfx}" == 'noninteractive' && $- != *i* ]] && break
    done
}

for rcfile in `__dot_bashrc_rcfiles_for_sourcing`; do
    . "$rcfile"
done
unset __dot_bashrc_rcfiles_for_sourcing

# vim: tabstop=4 shiftwidth=4 expandtab filetype=sh
