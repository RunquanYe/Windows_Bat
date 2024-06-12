:: ------------------------------------------------------------------------------------------------------------
:: This is a Windows Bat script program for providing customized auto-shutdown service.  
:: == Note: This file cannot be renamed as "shutdown".
:: Programmer: Runquan Ye
:: Date: 2024 June
:: Githup: https://github.com/RunquanYe/DemoProjects
:: Linkedin: https://www.linkedin.com/in/runquanye/
:: ------------------------------------------------------------------------------------------------------------


@ECHO OFF
SETLOCAL enabledelayedexpansion
:: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Global Variable~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
SET PROCESS_CHECK_TIME=10
SET WAIT_TIME=2



:: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Main Menu~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
:: Prompt the user for an option
:mainMenu
CLS
ECHO This is a Shutdown Bat Program, it provide multiple customized shutdown options. 
ECHO Programmer: Runquan Ye           Github:https://github.com/RunquanYe/DemoProjects
ECHO Please choose an following option:
ECHO ---------------------------------------------------------------------------------
ECHO == Press 1 to schdule a shutdown after a customized countdown.
ECHO == Press 2 to schdule a shutdown at a specific time in HH:MM(24h) format.
ECHO == Press 3 to schdule a shutdown after specific process was done with provided PID.
ECHO == Press (H, h) to display help instruction for this countdown Program
ECHO == Press (D, d) to display programmer introduction.
ECHO == Press (E, e) to exit the program.

ECHO.
SET /P "option=Enter your choice (1, 2, 3, H/h, D/d, E/e):  "

IF "%option%"=="1" (
    GOTO option1
) ELSE IF "%option%"=="2" (
    GOTO option2
) ELSE IF "%option%"=="3" (
    GOTO option3
) ELSE IF /I "%option%"=="H" (
    GOTO userGuide
) ELSE IF /I "%option%"=="D" (
    GOTO programmer
) ELSE IF /I "%option%"=="E" (
    GOTO endProcess
) ELSE (
    GOTO mainMenu
)



:: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~User Guide~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
:userGuide
ECHO.
ECHO.
ECHO Program Instruction:
ECHO -----------------------------------------------------------------------------------------------------------------
ECHO This program allows you to schedule a shutdown in multiple ways:
ECHO    Option 1. Countdown: You can set a timer to shutdown the system after a specified number of seconds.
ECHO    Option 2. Specific Time: You can set a specific time in HH:MM format to shutdown the system.
ECHO    Option 3. Process Completion: You can provide a PID, and the system will shutdown once the process is done.
ECHO == Note: This file cannot be renamed as 'shutdown'.
ECHO -----------------------------------------------------------------------------------------------------------------
ECHO.
PAUSE
GOTO mainMenu



:: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Option 1~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
:option1
CLS
ECHO You selected Option 1.
ECHO Process Completion: You need to input amount of seconds for countdown.
ECHO.

:inputCountDown
ECHO.
SET /P countdown=Enter the number of seconds for the countdown: 
:: Check if the input is a valid positive integer
FOR /F "tokens=* delims=0123456789" %%A in ("%countdown%") do (
    IF "%%A" neq "" (
        ECHO Invalid input. Please enter a positive integer.
        GOTO inputCountDown
    )
)
:: Check if the input is greater than 0
IF %countdown% leq 0 (
    ECHO Invalid input. Please enter a positive integer greater than 0.
    GOTO inputCountDown
)

:option1door2
ECHO.
ECHO == Press B/b to to go back main menu.
SET /P "checkProcess1=Are you sure to shutdown the computer in %countdown% seconds? (Y/y, N/n):  "
IF /I "%checkProcess1%"=="Y" (
    GOTO countdown
) ELSE IF /I "%checkProcess1%"=="N" (
    GOTO inputCountDown
) ELSE IF /I "%checkProcess1%"=="B" (
    GOTO mainMenu
) ELSE (
    ECHO #######################################
    ECHO Invalid Option. Please choose again.
    ECHO #######################################
    GOTO option1door2
)

:countdown
:: Countdown loop
ECHO Begin to countdown for %countdown% seconds.
for /L %%i in (%countdown%,-1,1) do (
    ECHO        Remain %%i s
    TIMEOUT /t 1 >NUL
)
ECHO Time's up. Start to shutdown.
SHUTDOWN /S /F /T 1
EXIT





:: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Option 2~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
:option2
CLS
ECHO You selected Option 2.
ECHO Process Completion: You need to input a the shutdown time in 24-hour format (HH:MM)
ECHO.

:inputShutdownTime
ECHO.
:: Prompt the user to enter the shutdown time in HH:MM format
SET /P "shutdownTime=Please enter the shutdown time HH:MM(24h format):  " 


:: Split the input time using the colon (:) delimiter
for /F "tokens=1-2 delims=:" %%a in ("%shutdownTime%") do (
    SET inputHour=%%a
    SET inputMinute=%%b
)

:: Validate hour and minute components
IF %inputHour% geq 0 IF %inputHour% lss 24 (
    IF %inputMinute% geq 0 IF %inputMinute% lss 60 (
        GOTO reasonableTime
    ) else (
        ECHO Invalid hour input. Please re-enter a valid minute 00 - 59.
        GOTO inputShutdownTime
    )
) else (
    ECHO Invalid minute input. Please re-enter a valid hour 00 - 23.
    GOTO inputShutdownTime
)

:reasonableTime
:: Get the current time in HH:MM:SS format
FOR /F "tokens=1-2 delims=:" %%a in ("%time%") do (
    SET currentHour=%%a
    SET currentMinute=%%b
)

IF %inputHour% lss %currentHour% (
    ECHO Notice: your schduled shutdown time is %inputHour%:%inputMinute%, and current time is %currentHour%:%currentMinute%.
    ECHO         The schdule shutdown time is will be in next day.
    GOTO scheduleShutdownTime
)



:scheduleShutdownTime
ECHO.
ECHO == Press B/b to to go back main menu.
SET /P "checkProcess2=Are you sure to shutdown the computer at %inputHour%:%inputMinute% ? (Y/y, N/n):  "
IF /I "%checkProcess2%"=="Y" (
    :: Create a scheduled task to shut down the computer at the specified time
    SCHTASKS /create /TN "ScheduledShutdown" /TR "shutdown /S /F /T 0" /SC once /ST %shutdownTime% /F
    ECHO The computer will be shutdown at %inputHour%:%inputMinute%.
    PAUSE
    GOTO endProcess
) ELSE IF /I "%checkProcess2%"=="N" (
    GOTO inputShutdownTime
) ELSE IF /I "%checkProcess2%"=="B" (
    GOTO mainMenu
) ELSE (
    ECHO #######################################
    ECHO Invalid Option. Please choose again.
    ECHO #######################################
    GOTO scheduleShutdownTime
)



:: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Option 3~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
:option3
CLS
ECHO You selected Option 3.
ECHO Process Completion: You need to provide a PID, and the system will shutdown once the process is done.
ECHO.

:getPID
ECHO ------------------------------------------------------------------------------------------------------------------------
ECHO How to find the specific PID of the process?
ECHO Way 1: Open Command Prompt and type "tasklist" to get a list of all running processes along with their PIDs.
ECHO Way 2: Press "Ctrl" + "Shift" + "Esc" to open Task Manager, go to the "Details" tab, and find the "PID" of the program.
ECHO ------------------------------------------------------------------------------------------------------------------------

:op3door1
ECHO.
ECHO == Press T/t to display current tasklist.
ECHO == Press N/n to process next step to input the PID.
ECHO == Press B/b to to go back main menu.
SET /P "confirmProcess3=Proceed next step? (T/t, N/n, B/b):  " 

IF /I "%confirmProcess3%"=="T" (
    TASKLIST
    ECHO.
    PAUSE
    GOTO monitorProgram
) ELSE IF /I "%confirmProcess3%"=="N" (
    GOTO monitorProgram
) ELSE IF /I "%confirmProcess3%"=="B" (
    GOTO mainMenu
) ELSE (
    :: op3door1 Default Case
    ECHO.
    ECHO.
    ECHO #######################################
    ECHO Invalid choice. Please choose again.
    ECHO #######################################
    GOTO op3door1
)


:monitorProgram
ECHO.
:: Prompt the user to enter the PID
SET /P "PID=Please enter the PID of the process you want to monitor:" 
SET /P "checkProcess3=Do you want to shutdown the computer after the process(PID: %PID%) was completed? (Y/y, N/n):  "

IF /I "%checkProcess3%"=="Y" (
    ECHO Monitoring process, PID %PID% ...
    GOTO check_pid
) ELSE (
    ECHO Cancel the action. Go back to main menu.
    TIMEOUT /T %WAIT_TIME% /NOBREAK >NUL
    GOTO mainMenu
)

:: Loop to check if the process with the given PID is running
:check_pid
TASKLIST /FI "PID eq %PID%" | FINDSTR /I "%PID%" >NUL
IF %ERRORLEVEL% EQU 0 (
    :: Process is still running, wait and check again
    TIMEOUT /T %PROCESS_CHECK_TIME% /NOBREAK >NUL
    GOTO check_pid
) ELSE (
    :: Process is not running, proceed to wait for shutdown time
    ECHO Process with PID %PID% is done.
    ECHO Shutting down now...
    TIMEOUT /T %WAIT_TIME% /NOBREAK >NUL
    SHUTDOWN /S /F /T 1
    EXIT
)



:: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Exit Program~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
:endProcess
ECHO Program done. Exiting...
:: Time out and wait for 3 second.
TIMEOUT /T %WAIT_TIME% /nobreak >NUL
ENDLOCAL & EXIT



:: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Display Programmer~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
:programmer
ECHO.
ECHO.
ECHO Programmer Introduction:
ECHO ***********************************************************************************************
ECHO    This program was created by Runquan Ye. It provides flexible shutdown scheduling options.
ECHO    Thank you for using my customized shutdown bat script. Hope you like it. 
ECHO    More info about me, please visit my relative account pages.
ECHO        Github:     https://github.com/RunquanYe
ECHO        Demo:       https://github.com/RunquanYe/DemoProjects
ECHO        Linkedin:   https://www.linkedin.com/in/runquanye
ECHO ***********************************************************************************************
ECHO.
PAUSE
GOTO mainMenu