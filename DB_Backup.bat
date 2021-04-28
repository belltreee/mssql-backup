
setlocal
set yy=%date:~0,4%
set mm=%date:~5,2%
set dd=%date:~8,2%
set hh=%time:~0,2%
set min=%time:~3,2%

SET BKUP_SQLSERVER_TO=%~dp0SQLSERVER
SET COPY_SQLSERVER_TO=[Path of the mount destination]

rem バックアップ先にコピー先のフォルダ作成
net use /user:backup \\[Serve IP Address or Server Host Name of the mount destination]  [Connect Passwd]
if not exist %COPY_SQLSERVER_TO% mkdir %COPY_SQLSERVER_TO%
net use /delete \\[Serve IP Address or Server Host Name of the mount destination]

rem SET COPY_CMD=C:\work\robocopy\Robocopy.exe
SET COPY_CMD=Robocopy.exe
SET COPY_OPTION= /S /E /LOG:%COPY_SQLSERVER_TO%\robocopy_%yy%%mm%%dd%.log /NP
rem SET COPY_OPTION= /S /E /LOG:%COPY_SQLSERVER_TO%\robocopy_%yy%%mm%%dd%.log /NP /tee

set DAYS_FILE_REMAIN_IN_HDD=1
set DAYS_FILE_REMAIN_IN_NAS=7

IF NOT EXIST %BKUP_SQLSERVER_TO% mkdir %BKUP_SQLSERVER_TO%

sqlcmd -E -S .\ -I -i %~dp0DB_Backup.sql -v BackUpDest = "%BKUP_SQLSERVER_TO%" Date = "%yy%%mm%%dd%" -o %BKUP_SQLSERVER_TO%\DB_Backup_DBS_SERVER_%yy%%mm%%dd%.log

net use /user:backup %COPY_SQLSERVER_TO%  [Connect Passwd]
%COPY_CMD% %COPY_OPTION% %BKUP_SQLSERVER_TO% %COPY_SQLSERVER_TO% 
net use /delete %COPY_SQLSERVER_TO%

rem ############# NAS上のバックアップファイルは DAYS_FILE_REMAIN_IN_NAS過ぎたら削除 #######################
forfiles /p %BKUP_SQLSERVER_TO% /d -%DAYS_FILE_REMAIN_IN_HDD% -c "cmd /c del /q @path"

rem ############# NAS上のバックアップファイルは DAYS_FILE_REMAIN_IN_NAS過ぎたら削除 #######################
net use /user:backup s: %COPY_SQLSERVER_TO%  [Connect Passwd]
forfiles /p s: /d -%DAYS_FILE_REMAIN_IN_NAS% -c "cmd /c del /q @path"
rem forfiles /p s: /d -%DAYS_FILE_REMAIN_IN_NAS% -c "cmd /c echo @path"
net use s: /delete /y


endlocal
rem pause
@echo on
