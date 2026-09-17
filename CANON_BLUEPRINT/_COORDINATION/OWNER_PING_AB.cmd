@echo off
REM Re-ping A+B when they go idle/STALE
cd /d "%~dp0"
python changebot.py --soft-ping
python _owner_ping_ab_once.py
python live_agent_coverage.py --once
pause
