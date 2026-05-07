# SJ Help Plugin

> Spring Boot · DDD 프로젝트를 위한 Claude Code 플러그인 — 자동 커밋, 보안 리뷰, 자동 테스트 생성, 위험 명령어 차단을 한 번에.

[![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-orange)](https://docs.anthropic.com/claude-code)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

---

## ✨ 주요 기능

| 명령어 | 설명 |
|--------|------|
| `/auto-commit` | 스테이징된 파일들을 파일별로 분리해 자동 커밋 메시지 생성 |
| `/security-review` | OWASP Top 10 기준으로 변경 코드 보안 취약점 리뷰 |
| `/test-orchestration <파일경로>` | Spring 컴포넌트 분석 후 JUnit 5 테스트 코드 자동 생성·검증 |
| **상시 적용 규칙** | `rm -rf`, `DROP TABLE`, `git push --force` 등 위험 명령어 자동 차단 + DDD 코드 컨벤션 강제 |

---

## 🚀 설치

Claude Code에서 한 번만 실행:

```
/plugin marketplace add kimsj0970/sj-help-plugin
/plugin install sj-help-plugin@sj-help
```

설치 즉시 슬래시 커맨드 사용 가능합니다.

### 선택: 프로젝트별 보안 셋업
`.env` 파일 커밋 경고 훅과 `.claudeignore`를 셋업하려면, 대상 프로젝트 루트에서:

```bash
curl -s https://raw.githubusercontent.com/kimsj0970/sj-help-plugin/main/scripts/setup.sh | bash
```

---

## 💡 사용 예시

**자동 커밋**
```
$ git add .
$ /auto-commit
✅ UserController.java  → [FEAT] 사용자 등록 API 추가
✅ UserService.java     → [FEAT] 회원가입 로직 구현
✅ application.yml      → [CHORE] DB 커넥션 풀 설정 변경
```

**보안 리뷰**
```
$ /security-review
⚠️ UserController.java:42
   - 취약점: SQL 인젝션 위험 (raw query 사용)
   - 해결: PreparedStatement 또는 JPA Repository로 전환
```

**자동 테스트 생성**
```
$ /test-orchestration src/main/java/com/example/UserService.java
✅ 생성: src/test/java/com/example/UserServiceTest.java
✅ 검증: 5개 테스트 케이스 통과
```

---

## 📚 더 자세한 정보

- [PLUGIN-GUIDE.md](PLUGIN-GUIDE.md) — 각 명령어의 동작 원리, 디렉토리 구조, 유지보수 가이드
- [skills/global-rules/SKILL.md](skills/global-rules/SKILL.md) — 상시 적용되는 안전 규칙·아키텍처 규칙 전문

---

## 📄 라이선스

MIT License — 자유롭게 사용·수정·배포 가능합니다.

## 🤝 기여

이슈와 PR을 환영합니다. 버그 제보나 기능 제안은 [Issues](https://github.com/kimsj0970/sj-help-plugin/issues)에 남겨주세요.
