: << 'CMDBLOCK'
@echo off
REM Copilot session hook wrapper.
REM Runs Python on Windows and exits 0 if Python is unavailable.

set "DEBUG_ENABLED=0"
set "DEBUG_LOG_FILE=%SUPERPOWERS_COPILOT_HOOK_DEBUG%"
if not "%SUPERPOWERS_COPILOT_HOOK_DEBUG%"=="" set "DEBUG_ENABLED=1"
if "%DEBUG_LOG_FILE%"=="" set "DEBUG_LOG_FILE=%TEMP%\superpowers-copilot-hook.log"

if "%~1"=="" (
    call :log run-hook.cmd invoked without script name
    exit /b 1
)

set "HOOK_DIR=%~dp0"

where py >nul 2>nul
if %ERRORLEVEL% equ 0 (
    call :log running py -3 "%HOOK_DIR%%~1"
    py -3 "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
    if not %ERRORLEVEL% equ 0 call :log py -3 exited with code %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)

where python >nul 2>nul
if %ERRORLEVEL% equ 0 (
    call :log running python "%HOOK_DIR%%~1"
    python "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
    if not %ERRORLEVEL% equ 0 call :log python exited with code %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)

REM No Python found - plugin still loads, bootstrap context is skipped.
call :log no Python interpreter found; skipping bootstrap context injection
exit /b 0

:log
if "%DEBUG_ENABLED%"=="1" (
    >>"%DEBUG_LOG_FILE%" echo [%date% %time%] %*
)
exit /b 0
CMDBLOCK

# Unix fallback for local testing in WSL/macOS/Linux
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_NAME="$1"
shift

DEBUG_LOG_FILE="${SUPERPOWERS_COPILOT_HOOK_DEBUG:-/tmp/superpowers-copilot-hook.log}"
log_debug() {
  if [[ -n "${SUPERPOWERS_COPILOT_HOOK_DEBUG:-}" ]]; then
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" >> "$DEBUG_LOG_FILE"
  fi
}

if command -v python3 >/dev/null 2>&1; then
  log_debug "running python3 ${SCRIPT_DIR}/${SCRIPT_NAME}"
  exec python3 "${SCRIPT_DIR}/${SCRIPT_NAME}" "$@"
fi
if command -v python >/dev/null 2>&1; then
  log_debug "running python ${SCRIPT_DIR}/${SCRIPT_NAME}"
  exec python "${SCRIPT_DIR}/${SCRIPT_NAME}" "$@"
fi

log_debug "no Python interpreter found; skipping bootstrap context injection"
exit 0
