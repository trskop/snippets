#!/bin/bash

set -e


readonly prefix="$HOME/opt/trskop"
readonly binDir="$HOME/bin"
readonly repoBaseUrl='git@github.com:trskop'
readonly -a gitRepositories=(
    "$repoBaseUrl/snippets.git"
)


function error()
{
    local -r -i exitCode="$1"; shift
    local -r format="$1"; shift

    printf "Error: $format\n" "$@" 1>&2
    exit $exitCode
}


function prepareDir()
{
    local -r dir="$1"; shift

    if [[ ! -d "$dir" ]]; then
        if ! mkdir -p "$dir"; then
            error 1 '%s: %s' "$dir" 'Failed to create directory.'
        fi
    fi
}


function gitClone()
{
    local -r url="$1"; shift
    local -r wd="$1"; shift

    (
        cd "$wd"
        git clone "$url"
    )
}


main()
{
    prepareDir "$prefix"
    prepareDir "$binDir"

    for repo in "${gitRepositories[@]}"; do
        gitClone "$repo" "$prefix"
    done
}


main "$@"

# vim: tabstop=4 shiftwidth=4 expandtab
