Description
===========

Reusable snippets of code, simple reusable scripts, etc.


Scripts
=======

Install Haskell Package in a Sandbox
------------------------------------

Script for sandboxed installation of Haskell packages. It's implemented as a
wrapper for [*cabal-install*][cabal-install] or [*cabal-dev*][cabal-dev]
(depending on command line options and availability of the commands on the
system).

Usage:

```
install-in-sandbox.sh [-C|-c] [-w WORKING_DIR] [SANDBOX_DIR] [-- CABAL_OPTIONS]
install-in-sandbox.sh {-h|--help}
```

Example for installing cabal-dev in a sandbox:

```
$ install-in-sandbox.sh /opt/cabal-dev/0.9.2 -- cabal-dev-0.9.2
```

Install [*ThreadScope*][ThreadScope] on Debian Linux:

```
$ apt-get install libgtk2.0-dev libpango1.0-dev libglib2.0-dev libcairo2-dev
$ install-in-sandbox.sh /opt/ThreadScope/0.2.2 -- gtk2hs-buildtools
$ install-in-sandbox.sh /opt/ThreadScope/0.2.2 -- threadscope-0.2.2
```

Install [*ghc-gc-tune*][ghc-gc-tune] on Debian Linux:

```
$ apt-get install gnuplot
$ install-in-sandbox.sh /opt/ghc-gc-tune/0.3 -- ghc-gc-tune-0.3
```


License
=======

If not specified otherwise then code is under BSD3 license, see `LICENSE.bsd3`
for full license text.


[cabal-dev]:
  http://hackage.haskell.org/package/cabal-dev
  "HackageDB: cabal-dev is a tool for managing development builds of Haskell projects."
[cabal-install]:
  http://www.haskell.org/haskellwiki/Cabal-Install
  "HaskellWiki: Command-line tool that automates fetching, configuration, compilation and installation of Haskell libraries and programs."
[ghc-gc-tune]:
  https://donsbot.wordpress.com/2010/07/05/ghc-gc-tune-tuning-haskell-gc-settings-for-fun-and-profit/
  "Don Stewart's Blog: ghc-gc-tune: Tuning Haskell GC settings for fun and profit"
[ThreadScope]:
  http://www.haskell.org/haskellwiki/ThreadScope
  "ThreadScope is a tool for performance profiling of parallel Haskell programs."
