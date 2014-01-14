@echo off

rem Copyright (c) 2014, Peter Trsko <peter.trsko@gmail.com>
rem
rem All rights reserved.
rem
rem Redistribution and use in source and binary forms, with or without
rem modification, are permitted provided that the following conditions are met:
rem
rem     * Redistributions of source code must retain the above copyright
rem       notice, this list of conditions and the following disclaimer.
rem
rem     * Redistributions in binary form must reproduce the above
rem       copyright notice, this list of conditions and the following
rem       disclaimer in the documentation and/or other materials provided
rem       with the distribution.
rem
rem     * Neither the name of Peter Trsko nor the names of other
rem       contributors may be used to endorse or promote products derived
rem       from this software without specific prior written permission.
rem
rem THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
rem "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
rem LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
rem A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
rem OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
rem SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
rem LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
rem DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
rem THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
rem (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
rem OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

set prefix=C:\opt
set link=%prefix%\batch-files
set registry=registry-entries.reg

if "%1"=="--update-registry" goto update_registry

if "%CD%"=="%link%" goto update_registry

if exist %link% (
    echo %link% already exists and this script will terminate.
    pause
    goto end
)

if not exist %prefix% (
    mkdir %prefix%
)

rem mklink [[/D] | [/H] | [/J]] LINK TARGET
rem
rem /D      Creates a directory symbolic link instead of file symbolic link.
rem /H      Creates a hard link instead of a symbolic link.
rem /J      Creates a Directory Junction.
rem LINK    Specifies the new symbolic link name.
rem TARGET  Specifies the path (relative or absolute) that the new link refers
rem         to.
rem
rem For details about Directory Junction see:
rem
rem   https://en.wikipedia.org/wiki/NTFS_junction_point
mklink /d %link% "%CD%"

:update_registry

rem regedit [/L:system|/R:user] [/S] importfile.REG
rem regedit [/L:system|/R:user] [/A] /E exportfile.REG "registry_key"
rem regedit [/L:system|/R:user] /C
rem
rem /A         Export non uni-code.
rem /S         Silent, i.e. hide confirmation box when importing files.
rem /E         Export registry file.
rem /L:system  Specify the location of the system.dat to use.
rem /R:user    Specify the location of the user.dat to use.
rem /C         Compress [filename] (Windows 98 only).
regedit /si registry-entries.reg

:end

rem vim: tabstop=4 shiftwidth=4 expandtab filetype=dosbatch
