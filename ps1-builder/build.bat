@ECHO off

SET "_parent=%~dp0"
SET "polyfile=%_parent%polyglot.bat"
SET "infile=%~dp1%~nx1"
SET "outfile=%~dp1%~n1.bat"

ECHO.
ECHO %polyfile%
ECHO +
ECHO %infile%
ECHO =
ECHO %outfile%
ECHO.

TYPE %polyfile% > %outfile%
ECHO.>>%outfile%
TYPE %infile% >> %outfile%

ECHO.
ECHO Done
ECHO.

TIMEOUT 5