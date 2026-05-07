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

# 이미지 경로 처리:
# WSL UNC 경로(\\wsl.localhost\...)는 BurntToast가 못 읽으므로
# Windows TEMP에 복사 후 로컬 경로 사용
$CatSrc  = Join-Path $PSScriptRoot "..\assets\cat.jpg"
$CatDest = Join-Path $env:TEMP "claude-sj-help-cat.jpg"

if (Test-Path $CatSrc) {
    # 첫 호출이거나 원본이 갱신됐으면 다시 복사
    if (-not (Test-Path $CatDest) -or ((Get-Item $CatSrc).Length -ne (Get-Item $CatDest).Length)) {
        Copy-Item -Path $CatSrc -Destination $CatDest -Force -ErrorAction SilentlyContinue
    }
}

if (Test-Path $CatDest) {
    New-BurntToastNotification -Text $Title, $Message -AppLogo $CatDest
} else {
    New-BurntToastNotification -Text $Title, $Message
}
