# Windows Toast Notification (BurntToast 기반)
# 호출: powershell.exe -File notify.ps1 stop|permission

param([string]$Event = "stop")

# BurntToast 모듈 점검 — 미설치 시 알림만 건너뛰고 hook은 정상 종료
if (-not (Get-Module -ListAvailable -Name BurntToast)) {
    exit 0
}
Import-Module BurntToast -ErrorAction SilentlyContinue

# 이벤트별 메시지
switch ($Event) {
    "stop"       { $Title = "🐱 Claude Code"; $Message = "작업 완료!" }
    "permission" { $Title = "🙀 Claude Code"; $Message = "승인 필요!" }
    default      { $Title = "Claude Code";    $Message = "알림" }
}

# 이미지 경로 (있으면 AppLogo로 첨부)
$CatPath = Join-Path $PSScriptRoot "..\assets\cat.jpg"
if (Test-Path $CatPath) {
    $CatPath = (Resolve-Path $CatPath).Path
    New-BurntToastNotification -Text $Title, $Message -AppLogo $CatPath
} else {
    New-BurntToastNotification -Text $Title, $Message
}
