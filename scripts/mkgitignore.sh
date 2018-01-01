#!/bin/bash

set -e


function haveCommand()
{
    hash "$1" >& /dev/null
}

function findSuitableEditor()
{
    local ed="${VISUAL:-${EDITOR}}"

    if [[ -n "$ed" ]]; then
        echo "$ed"

        return 0
    fi

    # 'sensible-editor' is Debian/Ubuntu specific.
    local -r -a editors=(
        'sensible-editor'
        'nvim'
        'vim'
        'vi'
        'mcedit'
        'nano'
        'emacs'
    )

    # Neither $VISUAL nor $EDITOR were defined, try to find something suitable.
    for editor in "${editors[@]}"; do
        if haveCommand "$editor"; then
            echo "$editor"

            return 0
        fi
    done

    return 1
}

function header()
{
    local -r beginningOrEnd="$1"; shift
    local -r title="$1"; shift

    local -r ten='##########'
    local -r sufix="##$ten$ten$ten$ten$ten$ten$ten"

    case "$beginningOrEnd" in
      begin) local -r prefix='{{{';;
      end) local -r prefix='}}}';;
      *) local -r prefix='';;
    esac

    printf '# %s %s %s\n' \
        "$prefix" "$title" "${sufix:0:$((72 - ${#title}))}"
}

function error()
{
    local -r -i exitCode="$1"; shift
    local -r format="$1"; shift

    printf "ERROR: $format\n" "$@" 1>&2

    exit $exitCode
}

function main()
{
    local -r tempdir="$(mktemp --tmpdir -d gitignore-tmp-XXXXXXXXXX)" || {
        error 1 '%s' "Failed to create temporary directory, exit(1)."
    }
    local -r repo="$tempdir/gitignore-repo"
    local -r list="$tempdir/list"
    local -r out="generated.gitignore"

    local -r ed="$(findSuitableEditor || echo '')"

    if [ -z "$ed" ]; then
        error 1 '%s\n       %s' \
            'No usable editor was found, exit(1).' \
            'Please define VISUAL or EDITOR environment variable and try again.'
    fi

    if ! haveCommand 'git'; then
        error 1 '%s\n       %s\n       %s' \
            'Git executable was not found, exit(1).' \
            'Please install Git on your system.' \
            'On Debian install package named "git-core".'
    fi

    git clone https://github.com/github/gitignore "$repo"

    # List files in repository, subdirectories first.
    {
        find "$repo" -mindepth 2 -name '*.gitignore' -print | sort
        find "$repo" -maxdepth 1 -name '*.gitignore' -print | sort
    } | sed -r "s/^.{${#repo}}\///" > "$list"

    "$ed" "$list"

    cat > "$out" << EOF
# This file was generated using:
#
#   https://github.com/trskop/snippets/blob/master/scripts/mkgitignore.sh
#
# and it's based on snippets taken from:
#
#   https://github.com/github/gitignore
EOF

    tr '\n' '\0' < $list | while IFS= read -d $'' file; do
        echo
        header begin "$file"
        cat "$repo/$file"
        header end "$file"
    done >> "$out"

    # Make sure, that $tempdir has always correct value or the following
    # command will be a huge risk.
    echo rm -fr "$tempdir"
    rm -fr "$tempdir"
}

main "$@"
