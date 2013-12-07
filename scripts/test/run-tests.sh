#!/bin/bash

declare -a testCases=(
    'bootstrap-001.sh'
    'bootstrap-002.sh'
    'call-trace-001.sh'
)

main()
{
    local -r parentDir="$(readlink --canonicalize-existing "${0%/*}")"
    local testCase=''

    for testCase in "${testCases[@]}"; do
        testCase="$parentDir/$testCase"
        if [[ -x "$testCase" ]]; then
            "$testCase" "$@"
        else
            echo "${testCase##*/}: File doesn't exist or is not executable."
        fi
    done
}

main "$@"

# vim: tabstop=4 shiftwidth=4 expandtab
