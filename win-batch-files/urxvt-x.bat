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

if -%1-==-- (
    set workingdir=%HOMEPATH%
    goto endif
)

set workingdir=%1
for /f %%i in ('C:\cygwin\bin\cygpath -u %1') do set workingdir=%%i

:endif

rem run.exe might coredump, we want to be able to find it in the future in a
rem common place.
cd C:\opt\batch-files

start C:\cygwin\bin\run.exe /usr/bin/urxvt-X.exe -display 127.0.0.1:0 -geometry 160x48 -e /bin/bash --login -c "\"cd '%workingdir%'; unset workingdir; exec /bin/bash\""

exit

rem vim: tabstop=4 shiftwidth=4 expandtab filetype=dosbatch
