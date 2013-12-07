#!/bin/bash


failure()
{
    echo "$testCaseName: Failure."
    exit 1
}

success()
{
    echo "$testCaseName: Success."
    exit 0
}

getFixtureFilePath()
{
    local -r startingPoint="$1"; shift
    local -r testCaseBaseName="$1"; shift
    local -r fileName="$1"; shift

    result="${testCaseBaseName%-[0-9][0-9][0-9].sh}-fixture/$fileName"
    result="$startingPoint/$result"

    echo "$result"
}

getResultFilePath()
{
    echo "$(getFixtureFilePath "$@").result"
}

getInclude()
{
    local result="$1"; shift
    local -r fileName="$1"; shift

    # .../scripts/test/call-trace-001.sh -> .../scripts/test

    # .../scripts/test -> .../scripts/lib/$fileName
    result="${result%/*}/functions/$fileName"

    echo "$result"
}

source "$(getInclude "${0%/*}" 'boilerplate.sh')"

testCase()
{
    local -r fixtureName='supported-ways-to-define-a-function'

    local -r startingPoint="${0%/*}"
    local -r testCaseName="${0##*/}"
    local -r fixtureFile="$(
        getFixtureFilePath "$startingPoint" "$testCaseName" "$fixtureName")"
    local -r resultFile="$(
        getResultFilePath "$startingPoint" "$testCaseName" "$fixtureName")"
    local -i printResult=0

    if (( $# > 0 )); then
        case "$1" in
          --print-result)
            printResult=1
            ;;
        esac
    fi

    insertFunctionBolierplate < "$fixtureFile" \
    | if (( printResult == 0 )); then
        cmp --silent "$resultFile" - && success || failure
    else
        cat
    fi
}

testCase "$@"

# vim: tabstop=4 shiftwidth=4 expandtab
