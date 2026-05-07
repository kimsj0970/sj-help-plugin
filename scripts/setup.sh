#!/bin/bash
# AI 에이전트 안전 환경 셋업 스크립트
# 실행: bash scripts/setup.sh

set -e

# 1. Git 훅 폴더 생성 (이미 있으면 무시됨)
mkdir -p .git/hooks
HOOK_FILE=".git/hooks/pre-commit"

# 2. pre-commit 훅 안전하게 추가
if [ -f "$HOOK_FILE" ]; then
  if grep -q "\.env" "$HOOK_FILE"; then
    echo "pre-commit 훅에 이미 .env 경고 설정이 존재합니다. 건너뜁니다."
  else
    echo "" >> "$HOOK_FILE"
    echo "# --- AI 보안 훅 (.env 경고) ---" >> "$HOOK_FILE"
    cat << 'EOF' >> "$HOOK_FILE"
if git diff --cached --name-only | grep -q '^\.env$'; then
  echo "🚨 삐빅! 주의: 커밋에 .env 파일이 포함되어 있습니다."
fi
EOF
    echo "✅ 기존 pre-commit 훅 파일에 .env 경고 로직을 추가했습니다."
  fi
else
  cat << 'EOF' > "$HOOK_FILE"
#!/bin/bash
if git diff --cached --name-only | grep -q '^\.env$'; then
  echo "🚨 삐빅! 주의: 커밋에 .env 파일이 포함되어 있습니다."
fi
exit 0
EOF
  echo "✅ pre-commit 훅 파일을 새로 생성했습니다."
fi

# 3. 권한 부여
chmod +x "$HOOK_FILE"

# 4. .claudeignore 파일 안전하게 추가
IGNORE_FILE=".claudeignore"
if [ -f "$IGNORE_FILE" ]; then
  if ! grep -q "^\.env$" "$IGNORE_FILE"; then
    echo "" >> "$IGNORE_FILE"
    echo ".env" >> "$IGNORE_FILE"
    echo "✅ 기존 .claudeignore 파일에 .env 항목을 추가했습니다."
  else
    echo ".claudeignore에 이미 .env가 포함되어 있습니다. 건너뜁니다."
  fi
else
  cat << 'EOF' > "$IGNORE_FILE"
node_modules/
.git/
build/
dist/
*.log
.env
EOF
  echo "✅ .claudeignore 파일을 새로 생성했습니다."
fi

echo ""
echo "✅ 모든 자동 설정이 완료되었습니다."
