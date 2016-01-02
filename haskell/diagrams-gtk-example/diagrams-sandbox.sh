#!/bin/bash

set -e

version=1.3

if ! hash ghc >& /dev/null; then
    echo 'GHC not found.' 1>&2
    exit 1
fi

cabal sandbox init --sandbox='cabal-sandbox'
cabal update

cabal install gtk2hs-buildtools-0.13.0.5
cabal install -fcairo -fgtk diagrams-$version
