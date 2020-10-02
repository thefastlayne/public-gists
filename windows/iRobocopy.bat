@echo off
echo.
echo ----Interactive Robocopy----
echo ----------------------------
echo.
:loop
set /p "source=Please Enter Source Location:       "
set /p "destination=Please Enter Destination Location:  "
echo.
echo "Source:       %source%"
echo "Destination:  %destination%"
echo.
set /p "confirmLocation=Does the configuration shown above look correct? (y/n) "
set task=ROBOCOPY "%source%" "%destination%" /COPYALL /S /MT:128 /R:3 /W:1 /LOG:"%source%\robocopy.log"
echo %task%
set true=echo Robocopy initiated. Please wait... & %task%
echo Your log file can be found in the source location you provided.
set false=goto loop
echo.
if %confirmLocation%==Y ( %true% )
if %confirmLocation%==y ( %true% )
if %confirmLocation%==YES ( %true% )
if %confirmLocation%==Yes ( %true% )
if %confirmLocation%==yes ( %true% )
if %confirmLocation%==N ( %false% )
if %confirmLocation%==n ( %false% )
if %confirmLocation%==NO ( %false% )
if %confirmLocation%==No ( %false% )
if %confirmLocation%==no ( %false% )