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

    # .../scripts/test/call-stack-001.sh -> .../scripts/test

    # .../scripts/test -> .../scripts/lib/call-trace.sh
    result="${result%/*}/functions/$fileName"

    echo "$result"
}

export BOOTSTRAP_INCLUDE="$(getInclude "${0%/*}" 'bootstrap.sh')"

testCase()
{
    local -r fixtureName='check-temporary-file-existence'

    local -r startingPoint="${0%/*}"
    local -r testCaseName="${0##*/}"
    local -r fixtureFile="$(
        getFixtureFilePath "$startingPoint" "$testCaseName" "$fixtureName")"
    local -r resultFile="$(
        getResultFilePath "$startingPoint" "$testCaseName" "$fixtureName")"

    local -r temporaryFile=$(bash "$fixtureFile") || failure
    trap "rm -f -- '$temporaryFile'" INT TERM EXIT

    [[ -x "$temporaryFile" ]] && success || failure
}

testCase "$@"

# vim: tabstop=4 shiftwidth=4 expandtab
