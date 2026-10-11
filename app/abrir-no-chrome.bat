@echo off
rem Abre o aplicativo no Chrome para ver as telas, sem celular e sem emulador.
rem Como usar: dois cliques neste arquivo. Precisa do Flutter instalado.
rem Para fechar o aplicativo, feche esta janela.
chcp 65001 >nul
setlocal
cd /d "%~dp0"

rem Usa o Flutter que estiver no PATH. Se não houver, tenta a pasta padrão
rem de instalação (C:\Users\seu-usuario\develop\flutter).
set "FLUTTER=flutter"
where flutter >nul 2>nul
if errorlevel 1 set "FLUTTER=%USERPROFILE%\develop\flutter\bin\flutter.bat"

if /i not "%FLUTTER%"=="flutter" if not exist "%FLUTTER%" (
  echo Não encontrei o Flutter neste computador.
  echo Veja como instalar no arquivo README.md desta pasta.
  echo.
  pause
  exit /b 1
)

echo Abrindo o LockMachine no Chrome. Leva cerca de meio minuto.
echo Para fechar o aplicativo, feche esta janela.
echo.
call "%FLUTTER%" run -d chrome --release --no-web-resources-cdn "--web-browser-flag=--window-size=500,900"

echo.
pause
