# Windows Toast Notification 발송 (PowerShell native)
# 호출: powershell.exe -File notify.ps1 stop|permission

param([string]$Event = "stop")

# 이벤트별 메시지
switch ($Event) {
    "stop"       { $Title = "🐱 Claude Code"; $Message = "작업 완료!" }
    "permission" { $Title = "🙀 Claude Code"; $Message = "승인 필요!" }
    default      { $Title = "Claude Code";    $Message = "알림" }
}

# 이미지 경로 (있으면 작은 원형 아이콘으로 표시)
$CatPath = Join-Path $PSScriptRoot "..\assets\cat.jpg"
if (Test-Path $CatPath) {
    $CatPath = (Resolve-Path $CatPath).Path
    $ImageTag = "<image placement=`"appLogoOverride`" hint-crop=`"circle`" src=`"$CatPath`"/>"
} else {
    $ImageTag = ""
}

# Toast XML 구성
$xmlString = @"
<toast>
  <visual>
    <binding template="ToastGeneric">
      <text>$Title</text>
      <text>$Message</text>
      $ImageTag
    </binding>
  </visual>
</toast>
"@

# Windows Runtime 어셈블리 로드 (3개 모두 필요)
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType=WindowsRuntime] > $null
[Windows.UI.Notifications.ToastNotification,        Windows.UI.Notifications, ContentType=WindowsRuntime] > $null
[Windows.Data.Xml.Dom.XmlDocument,                  Windows.Data.Xml.Dom,    ContentType=WindowsRuntime] > $null

# Toast 발송
$doc = New-Object Windows.Data.Xml.Dom.XmlDocument
$doc.LoadXml($xmlString)
$toast = [Windows.UI.Notifications.ToastNotification]::new($doc)
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Claude Code").Show($toast)
