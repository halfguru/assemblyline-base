@echo off
:: Configuration Options
set _Debug=0
set _Mode=normal

if "%_Debug%"=="1" echo Debug mode enabled

:main
echo Running main routine
call :subroutine
exit /b

:subroutine
echo Subroutine called
exit /b
