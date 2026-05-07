#!/bin/bash
# Windows Toast Notification 발송 스크립트
# 사용: notify.sh stop|permission

EVENT="${1:-unknown}"

# 이벤트별 메시지
case "$EVENT" in
  stop)
    TITLE="🐱 Claude Code"
    MESSAGE="작업 완료!"
    ;;
  permission)
    TITLE="🙀 Claude Code"
    MESSAGE="승인 필요!"
    ;;
  *)
    TITLE="Claude Code"
    MESSAGE="알림"
    ;;
esac

# 이미지 파일 처리 (있으면 작은 원형 아이콘으로 표시, 없으면 텍스트만)
CAT_FILE="${CLAUDE_PLUGIN_ROOT}/assets/cat.jpg"
if [ -f "$CAT_FILE" ]; then
  CAT_IMG=$(wslpath -w "$CAT_FILE" 2>/dev/null)
  IMAGE_TAG="<image placement=\"appLogoOverride\" hint-crop=\"circle\" src=\"$CAT_IMG\"/>"
else
  IMAGE_TAG="cat"
fi

# Windows Toast 알림 (WSL → PowerShell)
powershell.exe -NoProfile -Command "
  [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType=WindowsRuntime] | Out-Null
  \$xml = @'
<toast>
  <visual>
    <binding template=\"ToastGeneric\">
      <text>$TITLE</text>
      <text>$MESSAGE</text>
      $IMAGE_TAG
    </binding>
  </visual>
</toast>
'@
  \$doc = New-Object Windows.Data.Xml.Dom.XmlDocument
  \$doc.LoadXml(\$xml)
  [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Claude Code').Show([Windows.UI.Notifications.ToastNotification]::new(\$doc))
" 2>/dev/null

exit 0
