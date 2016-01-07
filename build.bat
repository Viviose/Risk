@ECHO OFF
CD "%~dp0"
SET racketdir="C:\Program Files\Racket"

IF EXIST "%~dp0dist\windows" rmdir /s /q "%~dp0dist\windows"
IF EXIST "%~dp0dist\windows" exit 1
IF EXIST "%~dp0release\Argo.zip" del "%~dp0release\Risk.zip"
IF EXIST "%~dp0release\Argo.zip" exit 1
ECHO "Installing rsound (If not already installed)"
"%racketdir%\raco.exe" pkg install rsound
ECHO "Compiling Server..."
"%racketdir%\raco.exe" exe "%~dp0src\risk.rkt"
ECHO "Creating distro..."
mkdir "%~dp0dist\windows"
"%racketdir%\raco.exe" distribute "%~dp0dist\windows" "%~dp0src\risk.exe"
del /F "%~dp0src\risk.exe" 
ECHO "Zipping package..."
"%racketdir%\Racket.exe" "%~dp0compress.rkt"
ECHO "Binaries in %~dp0\dist\windows\bin, packages in %~dp0\release"
ECHO "Finished."
