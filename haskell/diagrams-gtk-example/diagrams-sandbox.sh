#!/bin/bash

set -e

version=1.3

if ! hash ghc >& /dev/null; then
    echo 'GHC not found.' 1>&2
    exit 1
fi

cabal sandbox init --sandbox='cabal-sandbox'
cabal update

# GTK in version 13 and higher is not supported.
# See https://github.com/haskell/ThreadScope/issues/39
cabal install gtk2hs-buildtools-0.13.0.5 # --constraint='gtk >= 0.12.1 && <= 0.13'
cabal install -fcairo -fgtk diagrams-$version # --constraint='gtk >= 0.12.1 && < 0.13'
