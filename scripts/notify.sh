#!/bin/bash
# notify.ps1을 호출만 하는 얇은 wrapper
# 호출: notify.sh stop|permission

EVENT="${1:-stop}"

# WSL 경로 → Windows 경로 변환 후 PowerShell에 전달
PS1_FILE=$(wslpath -w "${CLAUDE_PLUGIN_ROOT}/scripts/notify.ps1" 2>/dev/null)

if [ -n "$PS1_FILE" ]; then
  powershell.exe -ExecutionPolicy Bypass -NoProfile -File "$PS1_FILE" "$EVENT" 2>/dev/null
fi

exit 0
