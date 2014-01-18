Description
===========

Reusable snippets of code, simple reusable scripts, etc.


Scripts
=======

Bash \*rc scripts
-----------------

Flexible collection of Bash \*rc scripts that is used on various systems that
include:

* Debian and Ubuntu Linux distributions.
* [Cygwin][] and [msysGit][] on Windows 7.

It might work on other systems as well but it wasn't tested.

To install this on Linux system just create symbolic link `~/.bashrc` that
points to `bashrc/dot.bashrc`:

    [ -e ~/.bashrc ] && mv ~/.bashrc{,~} # Backup
    ln -s {$PATH_TO_REPOSITORY/bashrc/dot,~/}.bashrc

Substitute `$PATH_TO_REPOSITORY` for whatever directory was used for this
repository clone, e.g. `~/opt/github.com/trskop/snippets`.

In [Cygwin][] environment above installation will work also, but note that on
some systems symbolic links created be [Cygwin][] are regular files and not
[NTFS symbolic links ][NTFS symbolic link]. See [StackOverflow: How to make
symbolic link with cygwin in Windows 7][] question and [Cygwin User's
Guide][Cygwin User's Guide -- Sybolic Links] for details how to change this. 

In Msys environment it is possible to use [NTFS symbolic links
][NTFS symbolic link], but then it will be necessary to do it for all component
scripts that you want enabled, because `dot.bashrc` script doesn't understand
[NTFS symbolic links][NTFS symbolic link]. On Windows 7 installation looks like
this:

    rem To simplify things go to the directory Msys Git considers as its home
    rem directory.

    mklink .bashrc %PATH_TO_REPOSITORY%\bashrc\dot.bashrc
    mklink .bash_aliases %PATH_TO_REPOSITORY%\bashrc\dot.bash_aliases
    mklink .bash_completion %PATH_TO_REPOSITORY%\bashrc\dot.bash_completion
    mklink .bash_functions %PATH_TO_REPOSITORY%\bashrc\dot.bash_functions
    mklink .bash_interactive %PATH_TO_REPOSITORY%\bashrc\dot.bash_interactive
    mklink .bash_noninteractive %PATH_TO_REPOSITORY%\bashrc\dot.bash_noninteractive

Where `%PATH_TO_REPOSITORY%` is where this repository was cloned to. It might
also be relative path as on POSIX systems.


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
[Cygwin User's Guide -- Sybolic Links]:
  http://cygwin.com/cygwin/cygwin-ug-net/using.html#pathnames-symlinks
  "Cygwin User's Guide, Chapter 3. Using Cygwin: Symbolic links"
[ghc-gc-tune]:
  https://donsbot.wordpress.com/2010/07/05/ghc-gc-tune-tuning-haskell-gc-settings-for-fun-and-profit/
  "Don Stewart's Blog: ghc-gc-tune: Tuning Haskell GC settings for fun and profit"
[msysGit]:
  http://code.google.com/p/msysgit/
  "msysGit: Git on Windows"
[NTFS symbolic link]:
  https://en.wikipedia.org/wiki/NTFS_symbolic_link
  "Wikipedia: NTFS symbolic link"
[StackOverflow: How to make symbolic link with cygwin in Windows 7]:
  https://stackoverflow.com/questions/3648819/how-to-make-symbolic-link-with-cygwin-in-windows-7
  "StackOverflow: How to make symbolic link with cygwin in Windows 7"
[ThreadScope]:
  http://www.haskell.org/haskellwiki/ThreadScope
  "ThreadScope is a tool for performance profiling of parallel Haskell programs."
