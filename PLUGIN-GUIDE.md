# SJ Help Plugin — 상세 가이드

[README.md](README.md)는 빠른 설치·사용 안내, 이 문서는 **각 기능의 동작 원리, 저장소 구조, 유지보수**를 다룹니다.

---

## 명령어 동작 원리

### `/auto-commit` — 파일별 자동 커밋
- AI가 `git diff --cached --name-only`로 스테이징된 파일 목록을 가져옵니다
- 각 파일에 대해 `git diff --cached <파일명>`으로 **변경된 부분만** 읽습니다 (전체 파일 읽기 금지 → 토큰 절약)
- Conventional Commits 형식(`[FEAT]`, `[FIX]`, `[CHORE]` 등)으로 1줄 메시지 생성
- 파일별로 `git commit <파일명>` 개별 실행 후 결과를 표로 보고

### `/security-review` — 변경 코드 보안 리뷰
- 15년 차 모의해킹 전문가 페르소나 적용
- `git diff --cached`로 변경분만 분석 (토큰 절약)
- OWASP Top 10 기준 검토:
  - SQL 인젝션 / NoSQL 인젝션
  - XSS (Cross-Site Scripting)
  - 하드코딩된 비밀번호·API 키·토큰
  - 인증·인가 누락
  - CSRF, SSRF 등
- 발견 시: `위험 파일·라인 / 취약점 설명 / 안전한 코드 예시` 3종 세트 제공

### `/test-orchestration <파일경로>` — JUnit 5 테스트 자동 생성
QA 매니저 페르소나가 [test-agent](agents/test-agent.md)를 spawn하여 작업 위임:

| 계층 | 적용 방식 |
|------|----------|
| Controller | `@WebMvcTest` 슬라이스 + `MockMvc` (Status Code, JSON Body 검증) |
| Service | `@ExtendWith(MockitoExtension.class)` 순수 단위 테스트 + given-when-then 패턴 |
| Repository / Adapter | `@DataJpaTest` 슬라이스 + JPA 정합성 검증 |

생성 후 `./gradlew test` 또는 `./mvnw test`로 자가 검증, 실패 시 최대 2회 자가 수정.

### `global-rules` 스킬 — 상시 적용
별도 호출 없이 모든 작업에 자동 적용되는 가드레일.

**Part 1. 안전 규칙**
- Self-Healing: 빌드/테스트 에러 시 사용자에게 즉시 보고하지 않고 1차 자가 수정 시도
- 정밀 타격 파일 수정: 전체 파일 덮어쓰기 금지, 변경 라인만 패치
- 위험 패턴 차단:
  - 쉘: `rm -rf /`, `rm -rf ~`, `DROP TABLE`, `TRUNCATE TABLE`, `git push --force`, 포크 폭탄, `mkfs.`, `dd if=...of=/dev/`
  - 파일: `.env`, `id_rsa`, `credentials.json`, `secrets.*`

**Part 2. Spring Boot DDD 아키텍처 규칙**
- 도메인 계층은 순수 Java Interface 리포지토리만, JPA 의존 금지
- 인프라 계층의 JPA Repository를 Adapter 패턴으로 감싸서 사용
- Web/Service 계층 DTO 분리, JPA Entity의 Controller 외부 노출 금지

전문은 [skills/global-rules/SKILL.md](skills/global-rules/SKILL.md) 참고.

---

## 📂 저장소 구조

```text
sj-help-main/
├── .claude-plugin/
│   ├── plugin.json           # 플러그인 메타데이터
│   └── marketplace.json      # 셀프-마켓플레이스 메타데이터 (source: "./")
├── commands/                 # 슬래시 커맨드 정의
│   ├── auto-commit.md
│   ├── security-review.md
│   └── test-orchestration.md
├── agents/                   # 서브 에이전트 정의
│   └── test-agent.md
├── skills/                   # 상시 적용 스킬
│   └── global-rules/
│       └── SKILL.md
├── scripts/
│   └── setup.sh              # 프로젝트별 보안 셋업 스크립트
├── .claudeignore             # 토큰 절약용 블랙리스트
├── README.md                 # GitHub 첫인상용 문서
└── PLUGIN-GUIDE.md           # 본 문서
```

---

## 🛠️ 유지보수 (관리자용)

### 변경 후 업데이트
```bash
git add .
git commit -m "[FEAT] 새 명령어 추가"
git push
```
사용자는 `/plugin marketplace update sj-help`로 최신 버전을 받습니다.

### 버전 관리
변경 시 [.claude-plugin/plugin.json](.claude-plugin/plugin.json)과 [.claude-plugin/marketplace.json](.claude-plugin/marketplace.json)의 `version` 필드를 함께 올려주세요. (Semantic Versioning 권장)

### 다른 마켓플레이스에 등록되고 싶을 때
큐레이션 카탈로그를 운영하는 누군가가 자기 marketplace.json에 다음을 추가하면 됩니다:
```json
{
  "name": "sj-help-plugin",
  "source": {
    "source": "github",
    "repo": "kimsj0970/sj-help-plugin"
  },
  "version": "0.1.0"
}
```

---

## 🔧 트러블슈팅

**Q. `/plugin install` 시 "source type not supported" 에러**
- A. Claude Code 버전이 오래된 경우 발생. `npm install -g @anthropic-ai/claude-code@latest` 로 업데이트.

**Q. `/auto-commit` 실행 시 변경사항이 없다고 나옴**
- A. `git add`로 스테이징을 먼저 해야 합니다. (`git status`로 확인)

**Q. `/test-orchestration` 빌드 실패**
- A. Gradle/Maven 프로젝트만 지원합니다. 빌드 도구가 다르면 동작하지 않을 수 있습니다.

**Q. WSL에서 `setup.sh` 실행 시 권한 에러**
- A. `chmod +x scripts/setup.sh` 후 재실행.
