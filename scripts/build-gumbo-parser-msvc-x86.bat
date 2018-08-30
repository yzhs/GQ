::
:: Copyright (c) 2015 Jesse Nicholson
::
:: Permission is hereby granted, free of charge, to any person obtaining a copy
:: of this software and associated documentation files (the "Software"), to deal
:: in the Software without restriction, including without limitation the rights
:: to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
:: copies of the Software, and to permit persons to whom the Software is
:: furnished to do so, subject to the following conditions:
::
:: The above copyright notice and this permission notice shall be included in
:: all copies or substantial portions of the Software.
::
:: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
:: IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
:: FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
:: AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
:: LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
:: OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
:: THE SOFTWARE.
::
@echo off

setlocal enabledelayedexpansion

:: Set GUMBO_VERSION to the extracted folder name, which includes the
:: version. So, as an example, in
:: PROJECT_ROOT_DIR\deps\gumbo-parser, you should have extracted
:: lets say Gumbo Parser 0.10.1. So you'll have
:: PROJECT_ROOT_DIR\deps\gumbo-parser\gumbo-parser-0.10.1\SOURCES.
:: Therefore, set GUMBO_VERSION to "gumbo-parser-0.10.1" like so:
:: GUMBO_VERSION=gumbo-parser-0.10.1
set GUMBO_VERSION=%1

:: Make sure the variables have been set.
if [%GUMBO_VERSION%] == [] GOTO RequiresSetup

:: Invoke the 32 bit Visual Studio command prompt environment, for build
:: tool stuff to be setup. If you have installed VS 2015 to a non-standard
:: place, or have an older version of VS, you will need to change this
:: line.
call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\Tools\vsvars32.bat"

:: Change the current directory to the gumbo-parser source directory.
cd ..\deps\gumbo-parser\%GUMBO_VERSION%\src

:: Delete any artifacts from previous builds.
call :Cleanup

:: Build a list of all source files for passing to the compiler.
for /f %%i in ('dir /B %cd%\*.c') do set SOURCES=%%i !SOURCES!

:: Build a list of all expected output obj files, for passing to the linker.
for /f %%j in ('dir /B %cd%\*.c') do set OBJS=%cd%\obj\%%~nj.obj !OBJS!

:: Build dir for obj output.
mkdir obj

:: Build and link 32 bit release version with no SSE2.
cl.exe /nologo /D_USRDLL /D_WINDLL /Fo%cd%\obj\ /O2 /Oi /Ot /GL /GF /GS- /Gy /fp:fast /guard:cf- /MD /LD /I %cd% /I %cd%\..\visualc\include %SOURCES% /link /DLL /MACHINE:x86 /OUT:gumbo_parser.dll

:: Generate corresponding LIB file.
LIB /NOLOGO /LTCG /MACHINE:x86 /OUT:gumbo_parser.lib %OBJS%

:: Generate output directories. If they exist, no harm, no errors.
mkdir ..\..\msvc
mkdir "..\..\msvc\include"
mkdir "..\..\msvc\include\gumboparser"
mkdir "..\..\msvc\Release x86"
mkdir "..\..\msvc\Release x86\lib"
mkdir "..\..\msvc\Debug x86"
mkdir "..\..\msvc\Debug x86\lib"
mkdir "..\..\msvc\Release x86 SSE2"
mkdir "..\..\msvc\Release x86 SSE2\lib"

:: Copy the build output (dll and lib files), as well as the headers to
:: the generated output directories.
xcopy /Y *.dll "..\..\msvc\Release x86\lib\"
xcopy /Y *.lib "..\..\msvc\Release x86\lib\"
xcopy /Y *.h "..\..\msvc\include\gumboparser\"
xcopy /Y "%cd%\..\visualc\include\*.h" "..\..\msvc\include\gumboparser\"

:: Delete any artifacts from previous builds.
call :Cleanup

:: Build and link 32 bit debug version with no SSE2.
cl.exe /nologo /D_USRDLL /D_WINDLL /Fo%cd%\obj\ /DEBUG /Zi /MDd /LD  /I %cd% /I %cd%\..\visualc\include %SOURCES% /link /DLL /MACHINE:x86 /OUT:gumbo_parser.dll

:: Generate corresponding LIB file.
LIB /NOLOGO /MACHINE:x86 /OUT:gumbo_parser.lib %OBJS%

:: Copy the build output (dll and lib files) to the generated output
:: directories.
xcopy /Y *.dll "..\..\msvc\Debug x86\lib\"
xcopy /Y *.lib "..\..\msvc\Debug x86\lib\"
xcopy /Y *.pdb "..\..\msvc\Debug x86\lib\"

:: Delete any artifacts from previous builds.
call :Cleanup

:: Build and link 32 bit release version with SSE2.
cl.exe /nologo /D_USRDLL /D_WINDLL /Fo%cd%\obj\ /O2 /Oi /Ot /GL /GF /GS- /Gy /fp:fast /guard:cf- /arch:SSE2 /MD /LD /I %cd% /I %cd%\..\visualc\include %SOURCES% /link /DLL /MACHINE:x86 /OUT:gumbo_parser.dll

:: Generate corresponding LIB file.
LIB /NOLOGO /LTCG /MACHINE:x86 /OUT:gumbo_parser.lib %OBJS%

:: Copy the build output (dll and lib files) to the generated output
:: directories.
xcopy /Y *.dll "..\..\msvc\Release x86 SSE2\lib\"
xcopy /Y *.lib "..\..\msvc\Release x86 SSE2\lib\"

:: Change back to the scripts directory.
cd %cd%\..\..\..\..\scripts

:: Quit
exit /B

:: This will print out help information to the console to assist the
:: user in correctly configuring the script in the event that the variables
:: were not setup.
:RequiresSetup
echo. & echo Please edit this batch file to have the following variables set correctly: & echo.
echo 	GUMBO_VERSION - Set this to the name of the Gumbo Parser source directory, the folder which includes the version number in it. & echo.
echo. & echo See script comments for more details.
timeout 10
exit /B

:Cleanup
:: Delete any artifacts from previous builds.
del /F %cd%\obj\*.obj
del /F %cd%\*.dll
del /F %cd%\*.lib
del /F %cd%\*.pdb