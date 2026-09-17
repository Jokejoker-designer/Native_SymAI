@echo off
REM Owner wake card for a stopped agent. Does not open the Cursor chat.
cd /d "%~dp0"
if "%~1"=="" (
  echo Usage: OWNER_WAKE.cmd AGENT_B
  echo        OWNER_WAKE.cmd --all-stale
  python owner_wake.py
  exit /b 1
)
python owner_wake.py %*
echo.
echo Paste CHECK MAILBOX into the roster chat. Mailbox cannot resume a stopped chat.
