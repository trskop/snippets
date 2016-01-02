Building
========

Install Dependencies
--------------------

```
cabal sandbox init
cabal update
cabal install gtk2hs-buildtools
cabal install -fcairo -fgtk diagrams-$version
```

There is also script `diagrams-sandbox.sh` that does all of the above, but it
uses `cabal-sandbox` as a Cabal sandbox directory instead of the default
(hidden) `.cabal-sandbox`.

Build Example
-------------

```
ghc -package-db "$(sed -nr '/^package-db:/{s/^[^:]+:[ \t]*//; p}' cabal.sandbox.config)" -rtsopts=all -O2 -Wall diagrams-gtk-example.hs
```
